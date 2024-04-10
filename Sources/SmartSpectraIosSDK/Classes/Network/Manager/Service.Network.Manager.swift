//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation
extension Service.Network {
    /**
     The `Manager` struct provides an interface for making network requests.
     */
    struct Manager {
        /// The underlying network layer for making requests.
        private let networkLayer = Service.Network()
        
        /**
         Fetches data from the specified URL using a GET request.
         
         - Parameters:
            - url: The URL to fetch the data from.
            - completion: The completion handler called when the fetch operation is complete.
                          Returns a `Result` object containing either the fetched data or an error.
         */
        func fetchData(from url: URL, completion: @escaping (Result<Data, Errors>) -> Void) {
            networkLayer.request(type: .Get, from: url, completion: completion)
        }
        /**
         Posts data to the specified URL using a POST request.
         
         - Parameters:
            - url: The URL to post the data to.
            - body: The data to be posted.
            - completion: The completion handler called when the post operation is complete.
                          Returns a `Result` object containing either the response data or an error.
         */
        func postData(from url: URL, body: Data, completion: @escaping (Result<Data, Errors>) -> Void) {
            networkLayer.request(type: .Post, from: url, body: body, completion: completion)
        }
        /**
         Put data to the specified URL using a PUT request.
         
         - Parameters:
            - url: The URL to Put the data to.
            - body: The data to be posted.
            - completion: The completion handler called when the post operation is complete.
                          Returns a `Result` object containing either the response data or an error.
         */
        func putData(from url: URL, body: Data, completion: @escaping (Result<String, Errors>) -> Void) {
            networkLayer.putRequest(type: .Put, from: url, body: body, completion: completion)
        }
    }
    
}
