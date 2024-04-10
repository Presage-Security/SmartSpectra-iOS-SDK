//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation

extension Model.Request {
    struct Complete: Codable {
        var id: String
        var upload_id: String
    }
}
