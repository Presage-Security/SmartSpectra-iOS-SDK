//
//  ScreeningPlotView.swift
//  SmartSpectraIosSDK
//
//  Created by Ashraful Islam on 10/24/24.
//
import SwiftUI
import AVFoundation
import PresagePreprocessing

struct ScreeningPlotView: View {
    private var core: PresagePreprocessing
    @Binding var isRecording: Bool
    @ObservedObject var sdk = SmartSpectraIosSDK.shared
    @State private var pulseRate: Float = 0
    @State private var breathingRate: Float = 0
    @State private var pulseTrace: [Presage_Physiology_Measurement] = []
    @State private var breathingTrace: [Presage_Physiology_Measurement] = []
    @State private var cameraPosition: AVCaptureDevice.Position
    @State private var runningMode: SmartSpectraMode

    init(core: PresagePreprocessing, isRecording: Binding<Bool>) {
        self.core = core
        _isRecording = isRecording
        cameraPosition = SmartSpectraIosSDK.shared.setup.cameraPosition
        runningMode = SmartSpectraIosSDK.shared.setup.configuration.runningMode
    }

    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Button(runningMode == .spot ? "Spot Mode": "Continuous Mode" , systemImage: runningMode == .spot ? "chart.dots.scatter" : "waveform.path") {
                    let duration = sdk.setup.configuration.duration
                    if runningMode == .spot {
                        runningMode = .continuous
                        sdk.setConfiguration(ContinuousModeConfiguration(maxDuration: duration))
                    } else {
                        runningMode = .spot
                        sdk.setConfiguration(SpotModeConfiguration(duration: duration))
                    }

                    DispatchQueue.main.async {
                        core.mode = sdk.setup.configuration.runningMode.presageMode
                        core.start(sdk.setup.configuration.duration)
                    }
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 24))
                .disabled(isRecording)

                Spacer()

                Button("Switch Camera", systemImage: "camera.rotate") {
                    if cameraPosition == .front {
                        cameraPosition = .back
                    } else {
                        cameraPosition = .front
                    }

                    sdk.setCameraPosition(cameraPosition)

                    DispatchQueue.main.async {
                        core.cameraPosition = sdk.setup.cameraPosition
                    }
                }
                .labelStyle(.iconOnly)
                .font(.system(size: 24))
                .disabled(isRecording)
            }

            if sdk.setup.configuration.runningMode == .continuous {
                GeometryReader { geometry in
                    HStack(alignment: .bottom) {
                        Label("Pulse Rate\n\(pulseRate > 0 ? "\(pulseRate) bpm" : "--")", systemImage: "heart.fill")
                            .font(.headline)
                            .shadow(color: .white, radius: 8)
                        Spacer()

                        plotTrace(data: pulseTrace, width: geometry.size.width/2, height: geometry.size.height, color: Color.red, recentCount: 200)
                            .shadow(color: .white, radius: 4)
                            .padding(.horizontal, 10)
                            .frame(width: geometry.size.width / 2)
                    }
                }
                .frame(height: 100)
                GeometryReader { geometry in
                    HStack(alignment: .bottom) {
                        Label("Breathing Rate\n\(breathingRate > 0 ? "\(breathingRate) bpm" : "--")", systemImage: "lungs.fill")
                            .font(.headline)
                            .shadow(color: .white, radius: 8)
                        Spacer()

                        plotTrace(data: breathingTrace, width: geometry.size.width/2, height: geometry.size.height, color: Color.blue, recentCount: 400)
                            .shadow(color: .white, radius: 4)
                            .padding(.horizontal, 10)
                            .frame(width: geometry.size.width / 2)
                    }
                }
                .frame(height: 100)
            }
            Spacer()
        }
        .padding()
        .onReceive(sdk.$metricsBuffer) { metricsBuffer in
            guard let metricsBuffer = metricsBuffer, metricsBuffer.isInitialized else { return }
            updateTraces(metricsBuffer)
            pulseRate = sdk.metricsBuffer?.pulse.rate.last?.value.rounded() ?? 0
            breathingRate = sdk.metricsBuffer?.breathing.rate.last?.value.rounded() ?? 0
        }
        .onAppear {
            print("ScreeningPlotView is disappearing")
            // reset the view states
            pulseTrace = []
            breathingTrace = []
            pulseRate = 0
            breathingRate = 0
        }
    }

    private func plotTrace(data: [Presage_Physiology_Measurement], width: CGFloat, height: CGFloat, color: Color, recentCount: Int) -> some View {
        let displayedData = data.suffix(recentCount)
        return Path { path in
            guard displayedData.count > 1 else { return }

            let minTime = displayedData.first!.time
            let maxTime = displayedData.last!.time
            let timeRange = maxTime - minTime

            let minValue = displayedData.map { $0.value }.min()
            let maxValue = displayedData.map { $0.value }.max()
            let valueRange = maxValue! - minValue!

            let points = displayedData.compactMap { measurement -> CGPoint? in
                let x = CGFloat((measurement.time - minTime) / timeRange) * width
                let y = height - CGFloat((measurement.value - minValue!) / valueRange) * height
                guard !x.isNaN, !y.isNaN else { return nil }
                return CGPoint(x: x, y: y)
            }

            // Ensure points array has at least one valid point
            guard let firstPoint = points.first else { return }

            path.move(to: firstPoint)
            points.dropFirst().forEach { point in
                path.addLine(to: point)
            }
        }
        .stroke(color, lineWidth: 2)
    }

    private func updateTraces(_ metricsBuffer: MetricsBuffer?) {
        //TODO: 9/6/24 While this works better now it is still kinda of hacky and need to be updated if its fixed in the server
        let newPulseTraces = metricsBuffer!.pulse.trace
        let newBreathingTraces = metricsBuffer!.breathing.upperTrace

        func mergeAndReplace(existing: inout [Presage_Physiology_Measurement], newTraces: [Presage_Physiology_Measurement]) {
            guard let firstNewTime = newTraces.first?.time else { return }

            // Find the index where overlap begins
            if let firstExistingIndex = existing.firstIndex(where: { $0.time >= firstNewTime }) {
                // Replace the overlapping section
                let overlapRange = firstExistingIndex..<existing.count
                existing.replaceSubrange(overlapRange, with: newTraces)

                // Ensure any remaining new traces beyond the overlap are appended
                if let lastNewTime = newTraces.last?.time,
                   let lastExistingTime = existing.last?.time,
                   lastNewTime > lastExistingTime {
                    let remainingNewTraces = newTraces.filter { $0.time > lastExistingTime }
                    existing += remainingNewTraces
                }
            } else {
                // No overlap: simply append all new traces
                existing += newTraces
            }
        }
        withAnimation {
            // Merge and replace for pulse traces
            mergeAndReplace(existing: &pulseTrace, newTraces: newPulseTraces)
            // Merge and replace for breathing traces
            mergeAndReplace(existing: &breathingTrace, newTraces: newBreathingTraces)
        }

    }
}
