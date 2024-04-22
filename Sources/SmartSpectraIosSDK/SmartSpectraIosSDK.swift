// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Combine

// Expose the data provider through your SDK's API
public class SmartSpectraIosSDK: ObservableObject {
    public static let shared = SmartSpectraIosSDK()
    @Published public var strictPulseRate: Double = 0
    @Published public var strictBreathingRate: Double = 0
    @Published public var jsonMetrics: [String: Any]?
    
    private var cancellables = Set<AnyCancellable>()

    public init() {
        observeSharedDataManager()
    }
    
    private func observeSharedDataManager() {
        
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
