import Foundation

internal class SmartSpectraConfig {
    internal var spotDuration: Double {
        didSet {
            if spotDuration < 20.0 {
                spotDuration = 20.0
                Logger.log("Warning: spotDuration is set below the minimum value. Clipping to 20.")
            } else if spotDuration > 120.0 {
                spotDuration = 120.0
                Logger.log("Warning: spotDuration is set above the maximum value. Clipping to 120.")
            }
        }
    }
    internal var showFps: Bool
    internal var saveJson: Bool

    internal init(spotDuration: Double = 30.0, showFps: Bool = false, saveJson: Bool = false) {
        self.spotDuration = spotDuration
        self.showFps = showFps
        self.saveJson = saveJson
    }
}
