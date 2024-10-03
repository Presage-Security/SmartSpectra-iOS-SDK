//
//  SmartSpectraSwiftView.swift
//
//
//  Created by Ashraful Islam on 8/13/24.
//

import Foundation
import SwiftUI
import PresagePreprocessing

@available(iOS 15.0, *)
public struct SmartSpectraView: View {
    @ObservedObject private var sdk = SmartSpectraIosSDK.shared
    
    public init(apiKey: String, spotDuration: Double = 20.0, showFps: Bool = false) {
        sdk.setApiKey(apiKey)
        sdk.setSpotDuration(spotDuration)
        sdk.setShowFps(showFps)
    }

    public var body: some View {
        VStack {
            SmartSpectraButtonView()
            SmartSpectraResultView(resultText: $sdk.resultText, resultErrorText: $sdk.resultErrorText)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
