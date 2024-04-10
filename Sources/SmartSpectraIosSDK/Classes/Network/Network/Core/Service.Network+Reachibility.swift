//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/29/23.
//

import Foundation

extension Service.Network {

    internal func checkNetworkConnectivity() -> Bool {
        guard let url = URL(string: "https://www.apple.com/") else {
            return false
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var isConnected = false
        
        let task = URLSession.shared.dataTask(with: url) { (_, response, error) in
            if error == nil, let httpResponse = response as? HTTPURLResponse {
                isConnected = (200...299).contains(httpResponse.statusCode)
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: .now() + 5)
        
        return isConnected
    }
}
