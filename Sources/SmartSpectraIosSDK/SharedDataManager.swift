//
//  SharedDataManager.swift
//  Sample Pressage App
//
//  Created by Bill Vivino on 4/4/24.
//

import Foundation
import Combine
import UIKit

class SharedDataManager: ObservableObject {
    static let shared = SharedDataManager()
    @Published public var pulsePleth: [(time: Double, value: Double)] = []
    @Published public var breathingPleth: [(time: Double, value: Double)] = []
    @Published public var hrValues: [(time: Double, value: Double)] = []
    @Published public var hrConfidence: [(time: Double, value: Double)] = []
    @Published public var rrValues: [(time: Double, value: Double)] = []
    @Published public var rrConfidence: [(time: Double, value: Double)] = []
    @Published public var rrl: [(time: Double, value: Double)] = []
    @Published public var apnea: [(time: Double, value: Bool)] = []
    @Published public var ie: [(time: Double, value: Double)] = []
    @Published public var amplitude: [(time: Double, value: Double)] = []
    @Published public var baseline: [(time: Double, value: Double)] = []
    @Published public var phasic: [(time: Double, value: Double)] = []
    @Published public var hrv: [(time: Double, value: Double)] = []
    @Published public var uploadDate: String?
    @Published public var version: String?
    @Published public var userID: String?
    @Published var strictPulseRate: Double = 0.0
    @Published var strictBreathingRate: Double = 0.0
    @Published var jsonMetrics: [String: Any]?
    @Published var meshPoints: [(x: Int16, y: Int16)] = []
   
    @Published var resultText: String = "No Results\n..."

    private init() {} // Private initializer to ensure singleton usage
    
    func updateResultText(with message: String) {
        self.resultText = message
    }
}
