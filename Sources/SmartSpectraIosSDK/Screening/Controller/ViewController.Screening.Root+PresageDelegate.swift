//
//  ViewController.Screening.Root + PresageDelegate.swift
//  Smart_Spectra_SDK
//
//  Created by Benyamin Mokhtarpour on 9/1/23.
//

import Foundation
import UIKit
import PresagePreprocessing

@available(iOS 15.0, *)
extension ViewController.Screening.Root: PresagePreprocessingDelegate {

    private func imageFromSampleBuffer(_ pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        let context = CIContext()
        if let image = context.createCGImage(ciImage, from: imageRect) {
            return image
        }
        return nil
    }

    public func frameWillUpdate(_ tracker: PresagePreprocessing!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!, timestamp: Int) {
        if let image = self.imageFromSampleBuffer(pixelBuffer) {
            DispatchQueue.main.async {
                self.imageHolder.image = UIImage(cgImage: image)
            }
        }

    }

    public func frameDidUpdate(_ tracker: PresagePreprocessing!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!) {

    }

    public func statusCodeChanged(_ tracker: PresagePreprocessing!, statusCode: StatusCode) {

        if statusCode != lastStatusCode {
            lastStatusCode = statusCode
            showToast(msg: tracker.getStatusHint(statusCode))

            // update button state
            if statusCode != StatusCode.ok {
                buttonState = .disable
            } else {
                buttonState = isRecording ? .running : .ready
            }
        }
        if sdkSetup.configuration.runningMode == .spot && sdkSetup.showFps {
            // update fps based on status code in spot mode
            updateFps()
        }

    }

    public func metricsBufferChanged(_ tracker: PresagePreprocessing!, serializedBytes: Data) {
        do {
            // Deserialize the data directly into the Swift Protobuf object
            let metricsBuffer = try MetricsBuffer(serializedBytes: serializedBytes)
//            print("Received metrics buffer. metadata: \(String(describing: metricsBuffer.metadata))")
//            print("Pulse: \(String(describing: metricsBuffer.pulse.rate.last?.value)), Breathing: \(String(describing: metricsBuffer.breathing.rate.last?.value))")
            // update metrics buffer
            DispatchQueue.main.async {
                self.sdk.metricsBuffer = metricsBuffer
            }

            if sdkSetup.configuration.runningMode == .spot {
                processingStatus = .processed
            }
            if sdkSetup.configuration.runningMode == .continuous && sdkSetup.showFps {
                //update fps based on metricsBuffer in continuous mode
                updateFps()
            }

        } catch {
            print("Failed to deserialize MetricsBuffer: \(error.localizedDescription)")
        }
    }

    public func timerChanged(_ timerValue: Double) {
        if counter != timerValue {
            counter = timerValue
            if counter == 0.0 && processingStatus == .idle {
                processingStatus = .processing
            }
        }
    }

    public func receiveDenseFacemeshPoints(_ points: [NSNumber]) {
        // Convert and unflatten the array into tuples of (Int16, Int16)
        let unflattenedPoints = stride(from: 0, to: points.count, by: 2).map { (points[$0].int16Value, points[$0 + 1].int16Value) }

        // Asynchronously update shared data manager
        DispatchQueue.main.async {
            self.sdk.meshPoints = unflattenedPoints
        }
    }

    fileprivate func updateFps() {
        // update fps
        let currentTime = Int(Date().timeIntervalSince1970 * 1000)

        if let lastTimestamp = lastTimestamp {
            let deltaTime = currentTime - lastTimestamp

            fpsValues.append(deltaTime)
            if fpsValues.count > movingAveragePeriod {
                fpsValues.removeFirst()
            }
            // TODO: 10/28/24: Fix this further upstream so this isn't necessary
            let averageDeltaTime = max(Double(fpsValues.reduce(0, +)) / Double(fpsValues.count), 0.0001)
            let movingAverageFPS = Int(round(1000 / averageDeltaTime))

            DispatchQueue.main.async {
                self.fpsLabel.text = "FPS: \(movingAverageFPS)"
            }
        }
        lastTimestamp = currentTime
    }

}
