//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation
import UIKit

extension ViewModel.Processing {

    /// Loops through a list of URLs and performs multipart uploads for each URL.
    /// - Parameters:
    ///   - model: The response model containing the necessary information for the uploads.
    internal func loopThroughUrls(model: Model.Response.PreSignedUrls) {
        let vid_id = model.id
        let urls = model.urls
        let upload_id = model.upload_id
        guard let _jsonData = self.jsonData else { return }
        let preprocessed_data = _jsonData
        let max_size = 5 * 1024 * 1024
        let max_len = getJsonSize()
        var tracker = 0
        var parts = [[String: Any]]()
        var num: Int = 0
  
        let serialQueue = DispatchQueue(label: "com.example.processing.serial")
        let dispatchGroup = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        var hasError = false
        
        for (index, url) in urls.enumerated() {
            dispatchGroup.enter()
            
            serialQueue.async {
                semaphore.wait()
                let part = index + 1
                num = index
                
                let fileData = self.retrieveChunkData(for: preprocessed_data, from: tracker, with: max_len, and: max_size)
                
                if !hasError {
                    self.performMultipartUpload(num: part, url: url, with: fileData) { stateOfChunkUpload, etag in
                        if stateOfChunkUpload {
                            self.handleChunkUploadCompletion(state: stateOfChunkUpload, etag: etag, for: part, and: index, in: urls.count, with: &parts) { state in
                                // Update the progress bar
                                let progress = Float(part) / Float(urls.count)
                                self.currentPercentage = progress
                                
                                if !state {
                                    hasError = true
                                }
                            }
                        } else {
                            hasError = true
                        }
                        tracker += max_size
                        
                        semaphore.signal()
                        dispatchGroup.leave()
                    }
                } else {
                    semaphore.signal()
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if !hasError {
                self.handleLoopCompletion(num: num, urlsCount: urls.count, vid_id: vid_id, upload_id: upload_id, with: &parts) { [weak self] state in
                    if state {
                        // Start the initial API call
                        self?.repollAPI(id: vid_id)
                    }
                }
            } else {
                self.delegate?.processingCompleted(nil)
                Logger.log("NETWORK ISSUE")
            }
        }
    }

    func repollAPI(id: String) {
        DispatchQueue.global().async { [weak self] in
            self?.callRetrieveData(id: id) { (state, model) in
                if model == nil {
                    // Repoll the API after 0.2 seconds
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                        self?.repollAPI(id: id)
                    }
                } else {
                    self?.delegate?.processingCompleted(model)
                }
            }
        }
    }

    /// Retrieves the chunk data from the preprocessed data based on the tracker and chunk size.
    /// - Parameters:
    ///   - preprocessedData: The preprocessed data.
    ///   - tracker: The tracker to determine the starting index of the chunk.
    ///   - maxLen: The maximum length of the data.
    ///   - maxSize: The maximum size of each chunk.
    /// - Returns: The data chunk.
    internal func retrieveChunkData(for preprocessedData: Data, from tracker: Int, with maxLen: Int, and maxSize: Int) -> Data {
        if (maxLen - tracker) < maxSize {
            return Data(preprocessedData[tracker..<maxLen])
        } else {
            return Data(preprocessedData[tracker..<(tracker + maxSize)])
        }
    }

    /// Performs a multipart upload for a given URL and file data.
    /// - Parameters:
    ///   - url: The URL to upload the file.
    ///   - fileData: The file data to be uploaded.
    ///   - completion: The completion closure to handle the result of the upload.
    internal func performMultipartUpload(num: Int, url: String, with fileData: Data, completion: @escaping (Bool, String) -> Void) {
        Logger.log("********")
        Logger.log("**** UPLOADING CHUNK NUMBER \(num) ****")
        Logger.log("********")
        
        repository.multiPartUpload(url: url, fileData: fileData) { result in
            switch result {
            case .success(let response):
                completion(true, response)
            case .failure(let error):
                completion(false, "")
                Logger.log("ERROR UPLOADING THE CHUNK", error.localizedDescription)
                self.delegate?.processingCompleted(nil)

            }
        }
    }
    
    /// Performs a multipart upload for a given URL and file data.
    /// - Parameters:
    ///   - url: The URL to upload the file.
    ///   - fileData: The file data to be uploaded.
    ///   - completion: The completion closure to handle the result of the upload.
    internal func callRetrieveData(id: String, completion: @escaping (Bool, Model.Response.ProcessedData?) -> Void) {
        Logger.log("********")
        Logger.log("**** Retrieving Data ****")
        Logger.log("********")
        let body = Model.Request.RetrieveData.init(id: id)
        repository.retrieveData(body: body) { result in
            switch result {
            case .success(let response):
                completion(true, response)
            case .failure(let error):
                completion(false, nil)
                Logger.log("ERROR UPLOADING THE CHUNK", error.localizedDescription)
                self.delegate?.processingCompleted(nil)
            }
        }
    }

    /// Handles the completion of a chunk upload.
    /// - Parameters:
    ///   - state: The state of the chunk upload.
    ///   - etag: The ETag value of the uploaded chunk.
    ///   - part: The part number of the uploaded chunk.
    ///   - index: The index of the current URL being processed.
    ///   - totalCount: The total count of URLs.
    ///   - parts: The array to store the uploaded parts information.
    internal func handleChunkUploadCompletion(state: Bool, etag: String, for part: Int, and index: Int, in totalCount: Int, with parts: inout [[String: Any]], completion: @escaping (Bool) -> Void) {
        if state {
            Logger.log("********")
            Logger.log("**** UPLOADING CHUNK NUMBER \(part) ****")
            Logger.log("********")
            
            parts.append(["ETag": etag, "PartNumber": part])
            if index == totalCount - 1 {
                Logger.log("********")
                Logger.log("**** UPLOADED LAST CHUNK ****")
                Logger.log("********")
            }
            completion(true)

        } else {
            completion(false)
            self.delegate?.processingCompleted(nil)

        }
    }

    /// Handles the completion of the loop and performs the final data upload.
    /// - Parameters:
    ///   - num: The value of `num`.
    ///   - urlsCount: The total count of URLs.
    ///   - vid_id: The video ID.
    ///   - upload_id: The upload ID.
    ///   - parts: The array of uploaded parts information.
    internal func handleLoopCompletion(num: Int, urlsCount: Int, vid_id: String, upload_id: String, with parts: inout [[String: Any]], completion: @escaping (Bool) -> Void) {
        let requestData = Model.Request.PreSignedUrls(file_size: Double(getJsonSize()))
        
        repository.completeDataUpload(num: num, UrlsCount: urlsCount, vid_id: vid_id, upload_id: upload_id, parts: &parts) { result in
            switch result {
            case .success(let response):
                Logger.log("LOOP HAS ENDED WITH SUCCESS")
                completion(true)
            case .failure(let error):
                Logger.log("Error generating upload URLs: \(error)")
                completion(false)
                self.delegate?.processingCompleted(nil)

            }
        }
    }

    /**
     Generates pre-signed URLs for the processing task.
     
     This method generates pre-signed URLs by calling the repository's `generateUploadUrls()` method.
     It handles the success and failure cases and provides appropriate comments for each case.
     */
    internal func generatePreSignedUrls(completion: @escaping (Model.Response.PreSignedUrls?) -> Void)  {
        // Create request data for pre-signed URLs
        let requestData = Model.Request.PreSignedUrls(file_size: Double(getJsonSize()))
        // Call repository method to generate upload URLs
        repository.generateUploadUrls(data: requestData) { result in
            switch result {
            case .success(let response):
                // Handle successful response and use the generated upload URLs
                completion(response)
            case .failure(let error):
                completion(nil)
                // Handle error
                Logger.log("Error generating upload URLs: \(error)")
                self.delegate?.processingCompleted(nil)
                
            }
        }
    }
    
    internal func getJsonSize() -> Int{
        let data =  self.jsonData
        // Get the size of the JSON object
        return data?.count ?? 0

    }
    

    

}
