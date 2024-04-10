//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/25/23.
//

import Foundation

extension ViewModel {
    class Processing: ProcessingViewModelProtocol {
        var jsonData: Data!
        weak var delegate: ProcessingDelegate? // Delegate to receive updates and notifications
        var repository = Service.Repository.Processing() // Repository for generating pre-signed URLs

        private let processingQueue = DispatchQueue(label: "com.example.processing", qos: .userInitiated)

        var currentPercentage: Float = 0 {
            didSet {
                delegate?.updateProgress(currentPercentage)
            }
        }
        
        /**
         Starts the processing task.
         
         This method begins the processing task by incrementing the progress percentage and simulating a processing delay.
         After each increment, it notifies the delegate of the updated percentage.
         */
        
        
        func sendProcessedDataToAPI() {
            generatePreSignedUrls { model in
                if let _model = model {
                    self.loopThroughUrls(model: _model)
                }
            }
        }
    }
}
