// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Combine

// Expose the data provider through your SDK's API
public class SmartSpectraIosSDK: ObservableObject {
    public static let shared = SmartSpectraIosSDK()
    @Published public var pulsePleth: [(time: Double, value: Double)] = []
    @Published public var breathingPleth: [(time: Double, value: Double)] = []
    @Published public var pulseValues: [(time: Double, value: Double)] = []
    @Published public var pulseConfidence: [(time: Double, value: Double)] = []
    @Published public var breathingValues: [(time: Double, value: Double)] = []
    @Published public var breathingConfidence: [(time: Double, value: Double)] = []
    @Published public var rrl: [(time: Double, value: Double)] = []
    @Published public var apnea: [(time: Double, value: Bool)] = []
    @Published public var ie: [(time: Double, value: Double)] = []
    @Published public var breathingAmplitude: [(time: Double, value: Double)] = []
    @Published public var breathingBaseline: [(time: Double, value: Double)] = []
    @Published public var phasic: [(time: Double, value: Double)] = []
    @Published public var hrv: [(time: Double, value: Double)] = []
    @Published public var strictPulseRate: Double = 0
    @Published public var strictBreathingRate: Double = 0
    @Published public var jsonMetrics: [String: Any]?
    @Published public var version: String?
    @Published public var uploadDate: String?
    @Published public var userID: String?

    private var cancellables = Set<AnyCancellable>()
    internal var configuration: SmartSpectraConfig

    private init(configuration: SmartSpectraConfig = SmartSpectraConfig()) {
        self.configuration = configuration
        observeSharedDataManager()
    }

    public func setSpotDuration(_ duration: Double) {
        configuration.spotDuration = duration
    }

    public func setShowFps(_ showFps: Bool) {
        configuration.showFps = showFps
    }

    private func observeSharedDataManager() {

        SharedDataManager.shared.$pulsePleth
            .receive(on: DispatchQueue.main)
            .sink { pulsePleth in
                self.pulsePleth = pulsePleth
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$hrValues
            .receive(on: DispatchQueue.main)
            .sink { hrValues in
                self.pulseValues = hrValues
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$hrConfidence
            .receive(on: DispatchQueue.main)
            .sink { hrConfidence in
                self.pulseConfidence = hrConfidence
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$breathingPleth
            .receive(on: DispatchQueue.main)
            .sink { breathingPleth in
                self.breathingPleth = breathingPleth
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$rrValues
            .receive(on: DispatchQueue.main)
            .sink { rrValues in
                self.breathingValues = rrValues
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$rrConfidence
            .receive(on: DispatchQueue.main)
            .sink { rrConfidence in
                self.breathingConfidence = rrConfidence
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$rrl
            .receive(on: DispatchQueue.main)
            .sink { rrl in
                self.rrl = rrl
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$apnea
            .receive(on: DispatchQueue.main)
            .sink { apnea in
                self.apnea = apnea
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$ie
            .receive(on: DispatchQueue.main)
            .sink { ie in
                self.ie = ie
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$amplitude
            .receive(on: DispatchQueue.main)
            .sink { amplitude in
                self.breathingAmplitude = amplitude
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$baseline
            .receive(on: DispatchQueue.main)
            .sink { baseline in
                self.breathingBaseline = baseline
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$phasic
            .receive(on: DispatchQueue.main)
            .sink { phasic in
                self.phasic = phasic
            }
            .store(in: &cancellables)
        
        SharedDataManager.shared.$hrv
            .receive(on: DispatchQueue.main)
            .sink { hrv in
                self.hrv = hrv
            }
            .store(in: &cancellables)
        
        SharedDataManager.shared.$version
            .receive(on: DispatchQueue.main)
            .sink { version in
                self.version = version
            }
            .store(in: &cancellables)
        
        SharedDataManager.shared.$uploadDate
            .receive(on: DispatchQueue.main)
            .sink { uploadDate in
                self.uploadDate = uploadDate
            }
            .store(in: &cancellables)
        
        SharedDataManager.shared.$userID
            .receive(on: DispatchQueue.main)
            .sink { userID in
                self.userID = userID
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$jsonMetrics
            .receive(on: DispatchQueue.main)
            .sink { String in
//                print(value)
                self.jsonMetrics = String
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$strictPulseRate
            .receive(on: DispatchQueue.main)
            .sink { value in
//                print(value)
                self.strictPulseRate = value
            }
            .store(in: &cancellables)

        SharedDataManager.shared.$strictBreathingRate
            .receive(on: DispatchQueue.main)
            .sink { value in
//                print(value)
                self.strictBreathingRate = value
            }
            .store(in: &cancellables)
    }
}
