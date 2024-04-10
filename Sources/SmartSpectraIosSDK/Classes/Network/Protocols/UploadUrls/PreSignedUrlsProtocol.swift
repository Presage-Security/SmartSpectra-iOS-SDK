//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation

/**
 The `PreSignedUrlsProtocol` defines the protocol for generating pre-signed URLs for file uploads.
 */
protocol PreSignedUrlsProtocol: AnyObject {
    /**
     Generates pre-signed URLs for file uploads.
     
     - Parameters:
        - data: The request data containing necessary information for generating URLs.
        - completion: The completion handler called when the generation is complete.
                      Returns a `Result` object containing either the generated URLs or an error.
     */

    func generateUploadUrls(data: Model.Request.PreSignedUrls, completion: @escaping (Result<Model.Response.PreSignedUrls, Error>) -> Void)
    func completeDataUpload(num: Int, UrlsCount: Int, vid_id: String, upload_id: String, parts: inout [[String: Any]], completion: @escaping (Result<Bool, Error>) -> Void) 
    func multiPartUpload(url: String, fileData: Data ,withCompletion completion: @escaping (Result<String, Error>) -> Void)
    
}
