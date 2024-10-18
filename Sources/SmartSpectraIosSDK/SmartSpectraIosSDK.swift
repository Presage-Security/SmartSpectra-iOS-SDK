// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Combine

import PresagePreprocessing

public typealias MetricsBuffer = Presage_Physiology_MetricsBuffer

// Expose the data provider through your SDK's API
public class SmartSpectraIosSDK: ObservableObject {
    public static let shared = SmartSpectraIosSDK()
    @Published public var meshPoints: [(x: Int16, y: Int16)] = []
    @Published public var metricsBuffer: MetricsBuffer? {
        didSet {
            updateResultText()
        }
    }
    
    @Published internal var resultText: String = "No Results\n..."
    @Published internal var resultErrorText: String = ""

    internal var configuration: SmartSpectraConfig
    internal var apiKey: String

    private init(apiKey: String = "", configuration: SmartSpectraConfig = SmartSpectraConfig()) {
        self.configuration = configuration
        self.apiKey = apiKey
    }

    public func setSpotDuration(_ duration: Double) {
        configuration.spotDuration = duration
    }

    public func setShowFps(_ showFps: Bool) {
        configuration.showFps = showFps
    }
    
    public func setRecordingDelay(_ delay: Int) {
        configuration.recordingDelay = delay
    }

    internal func setApiKey(_ apiKey: String) {
        self.apiKey = apiKey
    }

    private func updateResultText() {
        guard let metricsBuffer = metricsBuffer, metricsBuffer.isInitialized else {
            resultText = "No Results\n..."
            return
        }

        let strictPulseRate = round(metricsBuffer.pulse.strict.value)
        let strictBreathingRate = round(metricsBuffer.breathing.strict.value)
        let strictPulseRateInt = Int(strictPulseRate)
        let strictBreathingRateInt = Int(strictBreathingRate)
        
        let pulseRateText = "Pulse Rate: \(strictPulseRateInt == 0 ? "N/A": "\(strictPulseRateInt) BPM")"
        let breathingRateText = "Breathing Rate: \(strictBreathingRateInt == 0 ? "N/A": "\(strictBreathingRateInt) BPM")"
        resultText = "\(breathingRateText)\n\(pulseRateText)"

        if strictPulseRateInt == 0 || strictBreathingRateInt == 0 {
            // TODO: 9/30/24 Replace print with Swift Logging
            print("Insufficient data for measurement. Strict Pulse Rate: \(strictPulseRate), Strict Breathing Rate: \(strictBreathingRate)")
            resultErrorText = "Your data was insufficient for an accurate measurement. Please move to a better-lit location, hold still, and try again. For more guidance, see the tutorial in the dropdown menu of the 'i' icon next to 'Checkup.'"
        } else {
            resultErrorText = ""
        }
    }
}
