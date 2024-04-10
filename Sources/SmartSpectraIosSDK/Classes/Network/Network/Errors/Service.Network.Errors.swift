//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation


extension Service.Network {
    /**
     The `Errors` enum defines the error cases that can occur in the network layer.
     */
    enum Errors: Error {
        /**
         Represents a network error with an underlying error object.
         - Parameters:
            - underlyingError: The underlying error that caused the network error.
         */
        case networkError(underlyingError: Error)
        
        /**
         Indicates an invalid response received from the server.
         */
        case invalidResponse
        
        /**
         Represents a non-successful status code received in the response.
         - Parameters:
            - statusCode: The non-successful status code received.
         */
        case statusCode(Int)
        
        /**
         Indicates that the response data is empty.
         */
        case emptyData
        
        /**
         Indicates that the network connection failed.
         */

        case noNetworkConnection

        case AuthError

        /**
         A localized description of the error.
         */
        var localizedDescription: String {
            switch self {
            case .networkError(let underlyingError):
                return "Network Error: \(underlyingError.localizedDescription)"
            case .invalidResponse:
                return "Invalid Response"
            case .statusCode(let statusCode):
                return "Status Code Error: \(statusCode)"
            case .emptyData:
                return "Empty Data"
            case .noNetworkConnection:
                return "No Network Connection"
            case .AuthError:
                return "The Provided API KEY is not valid"
            }
        }
    }

}
