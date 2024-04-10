//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/25/23.
//

import Foundation
extension Service.Keys {
    enum API_KEY: String {
        case Test_Key
        
        static var value: String!
        
        static func setAPIKey(_ apiKey: String) {
            value = apiKey
        }
        
        static func currentAPIKey() -> String {
            return value
        }

    }
    
}
