//
//  SmartSpectraSwiftView.swift
//
//
//  Created by Ashraful Islam on 8/13/24.
//

import Foundation
import SwiftUI
import PresagePreprocessing
import AVFoundation

@available(iOS 15.0, *)
public struct SmartSpectraView: View {
    @ObservedObject private var sdk = SmartSpectraIosSDK.shared
    private let apiKey: String
    private let configuration: SmartSpectraConfiguration
    private let showFps: Bool
    private let recordingDelay: Int
    private let cameraPosition: AVCaptureDevice.Position

    public init(apiKey: String, configuration: SmartSpectraConfiguration, showFps: Bool = false, recordingDelay: Int = 3, cameraPosition: AVCaptureDevice.Position = .front) {
        self.apiKey = apiKey
        self.configuration = configuration
        self.showFps = showFps
        self.recordingDelay = recordingDelay
        self.cameraPosition = cameraPosition
    }

    public var body: some View {
        VStack {
            SmartSpectraButtonView()
            SmartSpectraResultView(resultText: $sdk.resultText, resultErrorText: $sdk.resultErrorText)
        }
        .onAppear {
            sdk.setApiKey(apiKey)
            sdk.setConfiguration(configuration)
            sdk.setShowFps(showFps)
            sdk.setRecordingDelay(recordingDelay)
            sdk.setCameraPosition(cameraPosition)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
