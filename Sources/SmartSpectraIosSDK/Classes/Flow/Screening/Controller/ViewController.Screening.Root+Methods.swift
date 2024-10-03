//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 5/23/23.
//

import Foundation
import UIKit
import AVFoundation
@available(iOS 15.0, *)
extension ViewController.Screening.Root {
    
    // UI CComponents methods
    internal func setupUIComponents() {
        addImagePreview()
        addBorderView()
        addRecordButton()
        addTimerView()
        addFPSLabel()
        addInfoButton()
    }
    
    internal func addRecordButton() {
        self.view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            recordButton.heightAnchor.constraint(equalToConstant: 80),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50)

        ])
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    internal func addBorderView() {
        view.addSubview(startOverlayView)
        view.addSubview(endOverlayView)
        view.addSubview(bottomOverlayView)
        
        let screenHeight = UIScreen.main.bounds.height
        let targetHeightPercentage: CGFloat = 0.3
        let targetHeight = screenHeight * targetHeightPercentage
        
        NSLayoutConstraint.activate([
            startOverlayView.leadingAnchor.constraint(equalTo: imageHolder.leadingAnchor),
            startOverlayView.topAnchor.constraint(equalTo: imageHolder.topAnchor),
            startOverlayView.bottomAnchor.constraint(equalTo: imageHolder.bottomAnchor),
            startOverlayView.widthAnchor.constraint(equalToConstant: 40),
            
            endOverlayView.trailingAnchor.constraint(equalTo: imageHolder.trailingAnchor),
            endOverlayView.topAnchor.constraint(equalTo: imageHolder.topAnchor),
            endOverlayView.bottomAnchor.constraint(equalTo: imageHolder.bottomAnchor),
            endOverlayView.widthAnchor.constraint(equalToConstant: 40),
            
            bottomOverlayView.leadingAnchor.constraint(equalTo: imageHolder.leadingAnchor, constant: 40),
            bottomOverlayView.trailingAnchor.constraint(equalTo: imageHolder.trailingAnchor, constant: -40),
            bottomOverlayView.bottomAnchor.constraint(equalTo: imageHolder.bottomAnchor),
            bottomOverlayView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80),
            bottomOverlayView.heightAnchor.constraint(equalToConstant: targetHeight)
        ])
    }
    
    internal func addImagePreview() {
        self.view.addSubview(imageHolder)
        
        NSLayoutConstraint.activate([
            imageHolder.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            imageHolder.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            imageHolder.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            imageHolder.topAnchor.constraint(equalTo: self.view.topAnchor, constant: topBarHeight)

        ])
    }

    internal func addTimerView() {
        self.view.addSubview(counterView)
        NSLayoutConstraint.activate([
            counterView.heightAnchor.constraint(equalToConstant: 60),
            counterView.widthAnchor.constraint(equalToConstant: 60),
            counterView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40),
            counterView.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor)
        ])
        
    }

    internal func addFPSLabel() {
        self.view.addSubview(fpsLabel)
        
        NSLayoutConstraint.activate([
            fpsLabel.heightAnchor.constraint(equalToConstant: 30),
            fpsLabel.widthAnchor.constraint(equalToConstant: 80),
            fpsLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40),
            fpsLabel.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor)
        ])
    }
    
    internal func addInfoButton() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(infoButton)
        
        // Positioning the button in the top-right corner with some padding
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            infoButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            infoButton.widthAnchor.constraint(equalToConstant: 40),
            infoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Add target to show the tip message when tapped
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    @objc private func infoButtonTapped() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Tip", message: "Please ensure the subject’s face, shoulders, and upper chest are in view and remove any clothing that may impede visibility. Please refer to Instructions For Use for more information.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @objc private func recordButtonTapped() {
        if buttonState == .ready {
            startRecording()
            buttonState = .running
            isRecording = true
        } else if buttonState == .running {
            stopRecording()
            buttonState = .ready
            isRecording = false
        } else {
            Logger.log("Recording button is disabled.")
        }
    }

    private func lockCameraSettings() {
        guard let device = videoDeviceInput?.device else {
                Logger.log("Error: videoDeviceInput is nil")
                return
            }
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.locked) {
                device.focusMode = .locked
            }
            
            if device.isWhiteBalanceModeSupported(.locked) {
                device.whiteBalanceMode = .locked
            }
            
            if device.isExposureModeSupported(.locked) {
                device.exposureMode = .locked
            }
            
            device.unlockForConfiguration()
        } catch {
            Logger.log("Error locking camera settings: \(error.localizedDescription)")
        }
    }
    
    
    private func unlockCameraSettings() {
        guard let device = videoDeviceInput?.device else {
                Logger.log("Error: videoDeviceInput is nil")
                return
            }
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            } else if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
            }
            
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            } else if device.isWhiteBalanceModeSupported(.autoWhiteBalance)  {
                device.whiteBalanceMode = .autoWhiteBalance
            }
            
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            } else if device.isExposureModeSupported(.autoExpose) {
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
        } catch {
            Logger.log("Error unlocking camera settings: \(error.localizedDescription)")
        }
    }
    // Method to start recording
    private func startRecording() {
        UIApplication.shared.isIdleTimerDisabled = true
        lockCameraSettings()
        core.buttonStateChanged(inFramework: true)
    }

    // Method to stop recording
    func stopRecording() {
        unlockCameraSettings()
        core.buttonStateChanged(inFramework: false)
    }
    
    func moveToProcessing() {
        DispatchQueue.main.async {
            self.stopRecording()
            let vc = ViewController.Processing.Root()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func stopCamera() {
        isRecording = false
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.counterView.removeFromSuperview()
                self.recordButton.removeFromSuperview()
            }
        }
    }
}

extension UIViewController {
    var topBarHeight: CGFloat {
        var top = self.navigationController?.navigationBar.frame.height ?? 0.0
        top += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return top
    }
}
