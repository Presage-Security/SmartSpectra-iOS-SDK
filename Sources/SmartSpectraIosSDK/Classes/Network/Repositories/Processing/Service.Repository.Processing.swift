//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/26/23.
//

import Foundation

/**
 The `UploadUrls` class is responsible for generating pre-signed URLs for data uploads.
 It conforms to the `PreSignedUrlsProtocol`.
 */

extension Service.Repository {
    class Processing: PreSignedUrlsProtocol {
        
        /**
         The network manager used for making network requests.
         */
        let service: Service.Network.Manager = .init()
        /**
         Generates pre-signed URLs for file uploads.
         
         - Parameters:
            - data: The request data containing necessary information for generating URLs.
            - completion: The completion handler called when the generation is complete.
                          Returns a `Result` object containing either the generated URLs or an error.
         */

        func generateUploadUrls(data: Model.Request.PreSignedUrls, completion: @escaping (Result<Model.Response.PreSignedUrls, Error>) -> Void) {
            // Validate the base URL and construct the full URL for generating upload URLs
            guard let _ = URL(string: Service.Routes.Base.URL.rawValue),
                  let url = URL(string: Service.Routes.Base.URL.rawValue + Service.Routes.URLs.UploadUrls.rawValue) else {
                return
            }
            
            do {
                // Encode the request data
                let encoder = JSONEncoder()
                let data = try encoder.encode(data)
                // Make the network request to generate upload URLs
                service.postData(from: url, body: data) { result in
                    switch result {
                    case .success(let responseData):
                        do {
                            
                            let decoder = JSONDecoder()
                            let response = try decoder.decode(Model.Response.PreSignedUrls.self, from: responseData)
                            completion(.success(response))
                        } catch {
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } catch {
                print("Error encoding model: \(error)")
            }

        }
        
        
        func multiPartUpload(url: String, fileData: Data ,withCompletion completion: @escaping (Result<String, Error>) -> Void) {

            guard let url = URL(string: url) else { return  }
            
            service.putData(from: url, body: fileData) { result in
                switch result {
                case .success(let etag):
                    completion(.success(etag))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        func retrieveData(body: Model.Request.RetrieveData, withCompletion completion: @escaping (Result<Model.Response.ProcessedData?, Error>) -> Void) {

            guard let _ = URL(string: Service.Routes.Base.URL.rawValue),
                  let url = URL(string: Service.Routes.Base.URL.rawValue + Service.Routes.URLs.RetrieveData.rawValue) else {
                return
            }

            do {
                // Encode the request data
                let encoder = JSONEncoder()
                let data = try encoder.encode(body)
                var hrValue: Double = 0.0
                var rrValue: Double = 0.0

                // Make the network request to generate upload URLs
                service.postData(from: url, body: data) { [weak self] result in
                    guard let self = self else {return}
                    print("POST DATA RESULT", result)
                    
                    switch result {
                    case .success(let responseData):
                        guard !responseData.isEmpty else {
                            completion(.success(nil))
                            return
                        }
                        
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                DispatchQueue.main.async {
                                    SharedDataManager.shared.jsonMetrics = json
                                }
                                let id = json["id"] as? String
                                let breath = json["breath"] as? [String: [String: Any]]
                                let breathingRates = breath?["rr"] as? [String: [String: Any]]
                                let pulse = json["pulse"] as? [String: [String: Any]]
                                let pulseRates = pulse?["hr"] as? [String: [String: Any]]

                                let uploadDate = json["upload_date"] as? String
                            
                                let arrayPulseRatesValues = (pulseRates?.values.map { $0["value"] as? Double }.compactMap { $0 })
                                
                                if let pulsePleth = pulse?["hr_trace"] as? [String: [String: Double]] {
                                    // The data might not be in increasing time order so sort it on time
                                    let timeHrPairs = pulsePleth.compactMap { key, value -> (time: Double, value: Double)? in
                                        if let time = Double(key), let value = value["value"] {
                                            return (time, value)
                                        }
                                        return nil  // Skip invalid entries rather than substituting with (0.0, 0.0)
                                    }.sorted(by: { $0.time < $1.time })  // Sort by time
                                    DispatchQueue.main.async {
                                        SharedDataManager.shared.pulsePleth = timeHrPairs
                                    }
                                }
                                
                                var strictPulseRate: Double?
                                if let arrayHrValuesUnwrapped = arrayPulseRatesValues,
                                arrayHrValuesUnwrapped.count > 0 {
                                    let hrValueSum = arrayHrValuesUnwrapped.reduce(0, +)    // take the sum
                                    strictPulseRate = hrValueSum / Double(arrayHrValuesUnwrapped.count) // take the average
                                    DispatchQueue.main.async {
                                        SharedDataManager.shared.strictPulseRate = strictPulseRate ?? 0.0
                                    }
                                }
                                
                                let arrayBreathRateValues = (breathingRates?.values.map { $0["value"] as? Double }.compactMap { $0 })

                                if let breathingPleth = breath?["rr_trace"] as? [String: [String: Double]] {
                                    // The data might not be in increasing time order so sort it on time
                                    let timeHrPairs = breathingPleth.compactMap { key, value -> (time: Double, value: Double)? in
                                        if let time = Double(key), let value = value["value"] {
                                            return (time, value)
                                        }
                                        return nil  // Skip invalid entries rather than substituting with (0.0, 0.0)
                                    }.sorted(by: { $0.time < $1.time })  // Sort by time
                                    // plot the data
                                    DispatchQueue.main.async {
                                        SharedDataManager.shared.breathingPleth = timeHrPairs
                                    }
                                }
                                
                                var strictBreathingRate: Double?
                                if let arrayRRValuesUnwrapped = arrayBreathRateValues,
                                   arrayRRValuesUnwrapped.count > 0 {
                                    let RRValueSum = arrayRRValuesUnwrapped.reduce(0, +)    // take the sum
                                    strictBreathingRate = RRValueSum / Double(arrayRRValuesUnwrapped.count) // take the average
                                    DispatchQueue.main.async {
                                        SharedDataManager.shared.strictBreathingRate = strictBreathingRate ?? 0.0
                                    }
                                }
                                
                                // Print other values
                                debugPrint("ID: \(id ?? "")")
                                debugPrint("Upload Date: \(uploadDate ?? "")")
                                if  let id = id
                                {
                                    let model: Model.Response.ProcessedData? = .init(
                                        id: id,
                                        hr: hrValue,
                                        rr: rrValue,
                                        strictPulseRate: strictPulseRate ?? 0.0,
                                        strictBreathingRate: strictBreathingRate ?? 0.0
                                    )
                                    completion(.success(model))
                                } else {
                                    completion(.failure(Service.Network.Errors.emptyData))
                                }
                                // You can access other values in a similar manner
                            } else {
                                completion(.failure(Service.Network.Errors.emptyData))
                            }
                        } catch {
                            completion(.failure(Service.Network.Errors.emptyData))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } catch {
                print("Error encoding model: \(error)")
            }

        }
        
        func completeDataUpload(num: Int, UrlsCount: Int, vid_id: String, upload_id: String, parts: inout [[String : Any]], completion: @escaping (Result<Bool, Error>) -> Void) {
            guard let _ = URL(string: Service.Routes.Base.URL.rawValue),
                  let url = URL(string: Service.Routes.Base.URL.rawValue + Service.Routes.URLs.Complete.rawValue) else {
                return
            }
            
            do {
                let _json: [String: Any] = [
                    "id": vid_id,
                    "upload_id": upload_id,
                    "parts": parts
                ]
                let data = try JSONSerialization.data(withJSONObject: _json)
                // Make the network request to generate upload URLs
                service.postData(from: url, body: data) { result in
                    switch result {
                    case .success(let _):
                        completion(.success(true))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } catch {
                print("Error encoding model: \(error)")
            }


        }

        
        
    }
}
