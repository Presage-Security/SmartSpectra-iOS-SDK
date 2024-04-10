//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/28/23.
//

import Foundation

public extension Model.Response {
    struct ProcessedData: Encodable {
        public var id: String
        public var hr: Double
        public var rr: Double
        
        enum CodingKeys: String, CodingKey {
            case id
            case hr
            case rr
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(hr, forKey: .hr)
            try container.encode(rr, forKey: .rr)
        }
    }
}
