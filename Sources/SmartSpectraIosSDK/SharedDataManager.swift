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
    
    @Published var resultView : SmartSpectraResultView = {
        let res = SmartSpectraResultView()
        res.translatesAutoresizingMaskIntoConstraints = false
        return res
    }()
    
//    @Published var resultView: SmartSpectraResultView = SmartSpectraResultView()
    
    private init() {} // Private initializer to ensure singleton usage
}

