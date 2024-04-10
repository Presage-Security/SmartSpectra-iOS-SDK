//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation

extension Model.Response {
    struct PreSignedUrls: Codable {
        var id: String
        var key: String
        var upload_id: String
        var urls: [String]
    }
}
