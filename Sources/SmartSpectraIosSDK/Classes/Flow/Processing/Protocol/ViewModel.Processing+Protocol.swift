//
//  ViewModel.Processing + Protocol.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/25/23.
//

import Foundation
/**
 The `ProcessingDelegate` protocol defines methods that a delegate can implement to receive updates and notifications during a processing task.
 
 It is responsible for passing data from view model to controller layer
 */
protocol ProcessingDelegate: AnyObject {
    /**
     Notifies the delegate of the current processing progress percentage.
     
     - Parameter percentage: The current progress percentage.
     */
    func updateProgress(_ progress: Float)
    /**
     Notifies the delegate that the processing task has been completed.
     */
    func processingCompleted(_ model: Model.Response.ProcessedData?)
}

/**
 The `ProcessingViewModelProtocol` protocol defines methods for generating pre-signed URLs during a processing task.
 */
protocol ProcessingViewModelProtocol {
    /**
     Generates pre-signed URLs for the processing task.
     */
    func sendProcessedDataToAPI()
}
