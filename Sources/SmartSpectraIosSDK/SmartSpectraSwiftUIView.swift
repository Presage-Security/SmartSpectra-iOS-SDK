//
//  SmartSpectraSwiftUIView.swift
//
//
//  Created by Ashraful Islam on 8/13/24.
//

import Foundation
import SwiftUI
import PresagePreprocessing

public struct SmartSpectraSwiftUIView: View {
    @ObservedObject var sharedDataManager = SharedDataManager.shared

    public init() {} // Provide a public initializer

    public var body: some View {
        VStack {
            SmartSpectraResultView(resultText: sharedDataManager.resultText)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
