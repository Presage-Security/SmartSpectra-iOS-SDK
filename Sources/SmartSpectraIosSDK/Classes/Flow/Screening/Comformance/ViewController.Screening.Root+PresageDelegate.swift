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
    
    public func errorHappened(_ errorCode: Int32) {
        if counter == 0 {
            return
        }
        switch errorCode {
        case 1: showToast(msg: "No face detected")
        case 2: showToast(msg: "Only one face is permitted")
        case 3: showToast(msg: "Move closer to camera")
        case 4: showToast(msg: "Center face in view")
        case 5: showToast(msg: "Increase light on face")
        case 6: showToast(msg: "Decrease light on face")
        case 7: showToast(msg: "Place more of chest in view")
        default:
            showToast(msg: "Hold still and record")
        }
        while errorCode != 0 {
            buttonState = .disable

            return
        }

        if buttonState == .ready || buttonState == .running {
            if counter < 60 {
                buttonState = .running
            } else {
                buttonState = .ready
            }
        } else {
            buttonState = .ready
        }

    }
    
    public func timerChanged(_ timerValue: Double) {
        if counter != 0 {
            counter = Int(timerValue)
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
//        let fileName = "output.json"
//        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//                    print("Failed to access document directory")
//                    return
//                }
//        let fileURL = documentDirectory.appendingPathComponent(fileName)
//        do {
//                    try _jsonData.write(to: fileURL, options: .atomic)
//                    print("JSON saved to \(fileURL)")
//                } catch {
//                    print("Failed to write JSON data to file: \(error)")
//                }
//        END FOR JSON SAVING
        
        self.jsonData = _jsonData
        if self.counter == 0 {
            self.moveToProcessing()
        }

    }
    
    
}
