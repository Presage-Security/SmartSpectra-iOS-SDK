//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation

extension Model.Request {
    /**
     The `PreSignedUrls` struct represents a request for pre-signed URLs.
     */
    struct PreSignedUrls: Codable {
        /// The file size for which pre-signed URLs are requested.
        var file_size: Double
        
        /// The settings for all pre-signed URLs.
        var all: All = .init(to_process: true)
    }
}
extension Model.Request.PreSignedUrls {
    /**
     The `All` struct represents the settings for all pre-signed URLs.
     */
    struct All: Codable {
        /// Indicates whether the URLs are to be processed.
        var to_process: Bool
    }
}
