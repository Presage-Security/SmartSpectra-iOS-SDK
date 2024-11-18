import Foundation
import AVFoundation
import PresagePreprocessing

public enum SmartSpectraMode {
    case spot
    case continuous

    // Internal helper to map to PresageMode
    internal var presageMode: PresageMode {
        switch self {
        case .spot:
            return .spot
        case .continuous:
            return .continuous
        }
    }
}

public protocol SmartSpectraConfiguration {
    var runningMode: SmartSpectraMode { get }
    var duration: Double { get set }
}

public struct SpotModeConfiguration: SmartSpectraConfiguration {
    public let runningMode: SmartSpectraMode = .spot

    public var duration: Double

    public init(duration: Double = 30.0) {
        self.duration = clipValue(duration, minValue: 20.0, maxValue: 120.0)
    }
}

public struct ContinuousModeConfiguration: SmartSpectraConfiguration {
    public var duration: Double {
        get { return maxDuration ?? 0.0 }
        set { maxDuration = newValue }
    }

    public let runningMode: SmartSpectraMode = .continuous

    var maxDuration: Double?

    public init(maxDuration: Double? = nil) {
        self.maxDuration = clipValue(maxDuration ?? 0.0, minValue: 20.0, maxValue: 120.0)
    }
}

internal class SmartSpectraSetup: ObservableObject {
    @Published internal var configuration: SmartSpectraConfiguration
    internal var showFps: Bool = false
    internal var recordingDelay: Int = 3
    internal var cameraPosition: AVCaptureDevice.Position = .front

    // defaults to 30 second spot if configuration is not supplied
    internal init(configuration: SmartSpectraConfiguration = ContinuousModeConfiguration(maxDuration: 30.0)) {
        self.configuration = configuration
    }
}

fileprivate func clipValue(_ value: Double, minValue: Double, maxValue: Double) -> Double {
    if value < minValue {
        Logger.log("Warning: duration \(value) is below the minimum value. Clipping to \(minValue).")
        return minValue
    } else if value > maxValue {
        Logger.log("Warning: duration \(value) is above the maximum value. Clipping to \(maxValue).")
        return maxValue
    } else {
        return value
    }
}
