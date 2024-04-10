//
//  SmartSpectraButtonView.swift
//  Sample Pressage App
//
//  Created by Bill Vivino on 4/4/24.
//

import Foundation
import SwiftUI
import PresagePreprocessing

public struct SmartSpectraButtonView: UIViewRepresentable {
    public typealias UIViewType = UIView
    var apiKey: String
    
    // Provide a public initializer that accepts an API key
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public func makeUIView(context: Context) -> UIView {
        let buttonView = UIView()
        let button = SmartSpectraButton.init(apiKey: apiKey)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.delegate = context.coordinator
        buttonView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
        ])
        return buttonView
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator: NSObject, SmartSpectraDelegate {
        public func passProcessedView(_ view: SmartSpectraResultView) {
            DispatchQueue.main.async {
                SharedDataManager.shared.resultView = view
            }
        }
    }
}
