//
//  SmartSpectraButtonView.swift
//  Sample Pressage App
//
//  Created by Ashraful Islam on 8/14/24.
//

import Foundation
import SwiftUI
import PresagePreprocessing

@available(iOS 15.0, *)
public struct SmartSpectraButtonView: View {
    @ObservedObject private var viewModel: SmartSpectraButtonViewModel
    var height: CGFloat = 56 // set to match android layout
    
    // Provide a public initializer that accepts an API key
    public init(apiKey: String) {
        self.viewModel = SmartSpectraButtonViewModel(apiKey: apiKey)
        SmartSpectraIosSDK.shared.setApiKey(apiKey)
    }
    
    public var body: some View {
        HStack {
            SmartSpectraCheckupButton {
                viewModel.smartSpectraButtonTapped()
            }
            Spacer()
            SmartSpectraInfoButton {
                viewModel.showActionSheet()
            }
            .frame(maxWidth: height)
        }
        .frame(maxWidth: 300, minHeight: height, maxHeight: height)
        .background(Color(red: 0.94, green: 0.34, blue: 0.36))
        .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }
}
