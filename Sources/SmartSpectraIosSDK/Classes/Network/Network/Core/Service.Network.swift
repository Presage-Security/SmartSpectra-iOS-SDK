//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/25/23.
//

import Foundation

extension Service {
    class Network {
        /// The type representing the completion handler for network requests.
        typealias CompletionHandler = (Result<Data, Errors>) -> Void
        typealias PutCompletionHandler = (Result<String, Errors>) -> Void
        /// The API key used for network requests.
        private let apiKey: String = Service.Keys.API_KEY.value
        /**
         Makes a network request of the specified type to the given URL.
         
         - Parameters:
            - type: The request type, such as GET or POST.
            - url: The URL to make the network request to.
            - body: The request body data, if any.
            - completion: The completion handler called when the network request is complete.
                          Returns a `Result` object containing either the response data or an error.
         */
        func request(type: RequestType, from url: URL, body: Data? = nil, completion: @escaping CompletionHandler) {
            // Check network connectivity
            guard checkNetworkConnectivity() else {
                completion(.failure(Errors.noNetworkConnection))
                return
            }
            

            var request = URLRequest(url: url)

            request.httpMethod = type.rawValue
            if  let _body = body  {
                request.httpBody = _body
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("\(_body.count)", forHTTPHeaderField: "Content-Length")

            }
            request.allHTTPHeaderFields = createHeaders()

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(Errors.networkError(underlyingError: error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(Errors.invalidResponse))
                    return
                }
                
                let statusCode = httpResponse.statusCode
                guard (200...299).contains(statusCode) else {
                    completion(.failure(Errors.statusCode(statusCode)))
                    return
                }
                if statusCode == 403 {
                    completion(.failure(Errors.AuthError))
                    preconditionFailure(Errors.AuthError.localizedDescription)
                } 

                guard let responseData = data else {
                    completion(.failure(Errors.emptyData))
                    return
                }
                
                completion(.success(responseData))
            }
            
            task.resume()

            
        }
        
        
       func putRequest(type: RequestType, from url: URL, body: Data, completion: @escaping PutCompletionHandler) {
           // Check network connectivity
           guard checkNetworkConnectivity() else {
               completion(.failure(Errors.noNetworkConnection))
               return
           }

           var request = URLRequest(url: url, timeoutInterval: .infinity)

           request.httpMethod = type.rawValue
           request.httpBody = body

           let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
               if let error = error {
                   completion(.failure(Errors.networkError(underlyingError: error)))
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse else {
                   completion(.failure(Errors.invalidResponse))
                   return
               }
               
               let statusCode = httpResponse.statusCode
               guard statusCode == 200 else {
                   completion(.failure(Errors.statusCode(statusCode)))
                   return
               }
               
               guard let _ = data else {
                   completion(.failure(Errors.emptyData))
                   return
               }
               let etag = httpResponse.allHeaderFields["Etag"] as! String
               completion(.success(etag))
           }
           
           task.resume()

           
       }
        /**
         Creates the HTTP headers for network requests.
         
         - Returns: A dictionary of HTTP headers.
         */
        private func createHeaders() -> [String: String] {
            return ["x-api-key": apiKey]
        }
    }
}
/**
 The `RequestType` enum defines the types of network requests.
 */
extension  Service.Network {
    enum RequestType: String {
        case Post   = "POST"
        case Put   = "PUT"
        case Get    = "GET"
    }
}
