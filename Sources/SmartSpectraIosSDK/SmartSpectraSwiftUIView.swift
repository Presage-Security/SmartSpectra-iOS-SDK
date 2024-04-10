//
//  SmartSpectraSwiftUIView.swift
//  Sample Pressage App
//
//  Created by Bill Vivino on 4/4/24.
//

import Foundation
import SwiftUI
import UIKit
import PresagePreprocessing


// Define a struct that conforms to UIViewRepresentable
public struct SmartSpectraSwiftUIView: UIViewControllerRepresentable {
    @ObservedObject var sharedDataManager = SharedDataManager.shared
    public func makeUIViewController(context: Context) -> SampleViewController {
        let viewController = SampleViewController()
        viewController.resultView = sharedDataManager.resultView
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: SampleViewController, context: Context) {
        uiViewController.resultView = sharedDataManager.resultView
    }
    
    public typealias UIViewControllerType = SampleViewController
    
    // Provide a public initializer
    public init() {}
}



public class SampleViewController: UIViewController {
    var resultView: SmartSpectraResultView = SharedDataManager.shared.resultView
//    lazy var resultView : SmartSpectraResultView = {
//        let res = SmartSpectraResultView()
//        res.translatesAutoresizingMaskIntoConstraints = false
//        return res
//    }()

    // This is the designated initializer for UIViewController
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        self.core.delegate = self
//        self.core.start()

        overrideUserInterfaceStyle = .light
//        addInfoButton()
        view.addSubview(resultView)
        NSLayoutConstraint.activate([
            resultView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            resultView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            resultView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            resultView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
        ])
//        view.addSubview(button)
//        NSLayoutConstraint.activate([
//            button.topAnchor.constraint(equalTo: resultView.bottomAnchor, constant: 255),
//            button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
//            button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
//        ])

    }
}

//extension SampleViewController: SmartSpectraDelegate {
//    func passProcessedView(_ view: SmartSpectraResultView) {
//        self.resultView = view
//    }
//}
