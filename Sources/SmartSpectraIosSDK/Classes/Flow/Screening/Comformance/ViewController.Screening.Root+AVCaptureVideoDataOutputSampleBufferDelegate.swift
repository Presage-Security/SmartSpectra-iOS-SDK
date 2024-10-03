//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/21/23.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit
import Vision
@available(iOS 15.0, *)
extension ViewController.Screening.Root: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Process the light data here
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()

        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let image = UIImage(cgImage: cgImage)

            // Process the image or extract light intensity
            if let lightIntensity = image.averageBrightness() {
                print("Light intensity: \(lightIntensity)")
            }
        }
    }

}
