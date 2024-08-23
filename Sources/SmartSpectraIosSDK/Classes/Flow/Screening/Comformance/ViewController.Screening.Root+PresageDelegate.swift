//
//  ViewController.Screening.Root + PresageDelegate.swift
//  Smart_Spectra_SDK
//
//  Created by Benyamin Mokhtarpour on 9/1/23.
//

import Foundation
import UIKit
import PresagePreprocessing

extension ViewController.Screening.Root: PresagePreprocessingDelegate {
    private func imageFromSampleBuffer(_ pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        let context = CIContext()
        if let image = context.createCGImage(ciImage, from: imageRect) {
            return image
        }
        return nil
    }

    public func frameWillUpdate(_ tracker: PresagePreprocessing!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!, timestamp: Int) {
        if let image = self.imageFromSampleBuffer(pixelBuffer) {
            DispatchQueue.main.async {
                self.imageHolder.image = UIImage(cgImage: image)
            }
        }

    }
    
    public func frameDidUpdate(_ tracker: PresagePreprocessing!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!) {
        
    }
    
    public func statusCodeChanged(_ tracker: PresagePreprocessing!, statusCode: StatusCode) {
        
        if statusCode != lastStatusCode {
            lastStatusCode = statusCode
            showToast(msg: tracker.getStatusHint(statusCode))
            
            // update button state
            if statusCode != StatusCode.ok {
                buttonState = .disable
            } else {
                buttonState = isRecording ? .running : .ready
            }
        }
        
        if sdkConfig.showFps {
            // update fps
            let currentTime = Int(Date().timeIntervalSince1970 * 1000)
            
            if let lastTimestamp = lastTimestamp {
                let deltaTime = currentTime - lastTimestamp
                
                fpsValues.append(deltaTime)
                if fpsValues.count > movingAveragePeriod {
                    fpsValues.removeFirst()
                }
                
                let averageDeltaTime = Double(fpsValues.reduce(0, +)) / Double(fpsValues.count)
                let movingAverageFPS = Int(round(1000 / averageDeltaTime))
                
                DispatchQueue.main.async {
                    self.fpsLabel.text = "FPS: \(movingAverageFPS)"
                }
            }
            lastTimestamp = currentTime
        }

    }
    
    public func timerChanged(_ timerValue: Double) {
        if counter != 0 {
            counter = Int(timerValue)
        }
    }
    
    public func receiveDenseFacemeshPoints(_ points: [NSNumber]) {
        // Convert and unflatten the array into tuples of (Int16, Int16)
        let unflattenedPoints = stride(from: 0, to: points.count, by: 2).map { (points[$0].int16Value, points[$0 + 1].int16Value) }

        // Asynchronously update shared data manager
        DispatchQueue.main.async {
            SharedDataManager.shared.meshPoints = unflattenedPoints
        }
    }
    
    public func receiveJsonData(_ jsonData: [AnyHashable : Any]!)  {
        guard var _tmpJSON = jsonData else { fatalError("Can Not Have Null")}
        var existingSettings = jsonData["setting"] as? [String: Any] ?? [:]

        // Get the device's OS version
        let osVersion = UIDevice.current.systemVersion
        
        // Get the device's model
        let deviceModel = UIDevice.current.model
        
        // Add "OS_Version" and "Phone_Model" to the existing "setting" dictionary
        existingSettings["OS_Version"] = osVersion
        existingSettings["Phone_Model"] = deviceModel
        
        // Update the "setting" key with the combined dictionary
        _tmpJSON["setting"] = existingSettings
        

        // Encode the updated dictionary back to JSON data
        guard  let _jsonData = try? JSONSerialization.data(withJSONObject: _tmpJSON, options: []) else {
            fatalError("JSON DATA HAS SOME ISSUE")
        }
        
//        FOR JSON SAVING
        //TODO: JSON data has too many precision for rr_points. Needs to be limited to 3
        if sdkConfig.saveJson {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())
            let fileName = "output_\(timestamp).json"
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Failed to access document directory")
                return
            }
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            do {
                try _jsonData.write(to: fileURL, options: .atomic)
                print("JSON saved to \(fileURL)")
            } catch {
                print("Failed to write JSON data to file: \(error)")
            }
        }
//        END FOR JSON SAVING
        
        self.jsonData = _jsonData
        if self.counter == 0 {
            self.moveToProcessing()
        }

    }
    
    
}
