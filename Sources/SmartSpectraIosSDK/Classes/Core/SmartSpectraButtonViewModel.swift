//
//  SmartSpectraButtonViewModel.swift
//
//
//  Created by Ashraful Islam on 8/14/23.
//

import Foundation
import UIKit
import Combine
import SwiftUI
@available(iOS 15.0, *)
/// A custom button with predefined appearance and behavior for SmartSpectra SDK.
final class SmartSpectraButtonViewModel: ObservableObject {
    
    internal let sdk = SmartSpectraIosSDK.shared
    public let responseSubject = PassthroughSubject<String, Never>()

    public init() {
        // Empty public initializer
    }
    
    private func showTutorialAndAgreementIfNecessary(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let walkthroughShown = UserDefaults.standard.bool(forKey: "WalkthroughShown")
            let hasAgreedToTerms = UserDefaults.standard.bool(forKey: "HasAgreedToTerms")
            let hasAgreedToPrivacyPolicy = UserDefaults.standard.bool(forKey: "HasAgreedToPrivacyPolicy")
            
            func showAgreements() {
                if !hasAgreedToTerms {
                    self.presentUserAgreement {
                        showPrivacyPolicy()
                    }
                } else {
                    showPrivacyPolicy()
                }
            }
            
            func showPrivacyPolicy() {
                if !hasAgreedToPrivacyPolicy {
                    self.presentPrivacyPolicy(completion: completion)
                } else {
                    completion?()
                }
            }
            
            if !walkthroughShown {
                self.handleWalkTrough {
                    showAgreements()
                }
            } else {
                showAgreements()
            }
        }
    }


    internal func handleWalkTrough(completion: (() -> Void)? = nil) {
        let imagePageVC = ImagePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        imagePageVC.onTutorialCompleted = completion
        findViewController()?.present(imagePageVC, animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "WalkthroughShown")
    }
    
    private func presentUserAgreement(completion: (() -> Void)? = nil) {
        checkInternetConnectivity { [weak self] isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    let agreementViewController = ViewController.Agreement.Root()
                    agreementViewController.onCompletion = completion
                    let navigationController = UINavigationController(rootViewController: agreementViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    navigationController.modalTransitionStyle = .coverVertical

                    self?.findViewController()?.present(navigationController, animated: true, completion: nil)
                } else {
                    self?.showNoInternetConnectionAlert()
                }
            }
        }
    }
    
    private func presentPrivacyPolicy(completion: (() -> Void)? = nil) {
        checkInternetConnectivity { [weak self] isConnected in
            DispatchQueue.main.async {
                if isConnected {
                    let privacyPolicyViewController = ViewController.PrivacyPolicy.Root()
                    privacyPolicyViewController.onCompletion = completion
                    let navigationController = UINavigationController(rootViewController: privacyPolicyViewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    navigationController.modalTransitionStyle = .coverVertical

                    self?.findViewController()?.present(navigationController, animated: true, completion: nil)
                } else {
                    self?.showNoInternetConnectionAlert()
                }
            }
        }
    }
    
    private func checkInternetConnectivity(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://www.google.com") else {
            completion(false)
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    private func showNoInternetConnectionAlert() {
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    func openSafari(withURL urlString: String) {
        guard let url = URL(string: urlString) else {
            return // Invalid URL, handle error or show an alert
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // Add options
        actionSheet.addAction(UIAlertAction(title: "Show Tutorial", style: .default) { _ in
            UserDefaults.standard.set(false, forKey: "WalkthroughShown")
            self.handleWalkTrough()
        })
        actionSheet.addAction(UIAlertAction(title: "Instructions for Use", style: .default) { _ in
            self.openSafari(withURL: "https://api.physiology.presagetech.com/instructions")
        })
        actionSheet.addAction(UIAlertAction(title: "Terms of Service", style: .default) { _ in
            self.presentUserAgreement()
        })
        actionSheet.addAction(UIAlertAction(title: "Privacy Policy", style: .default) { _ in
            self.presentPrivacyPolicy()
        })

        actionSheet.addAction(UIAlertAction(title: "Contact Us", style: .default) { _ in
            self.openSafari(withURL: "https://api.physiology.presagetech.com/contact")
        })
        

        // Add cancel button with red text color
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Handle cancellation
        }
        cancelButton.setValue(UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00), forKey: "titleTextColor")
        actionSheet.addAction(cancelButton)
        let viewController = self.findViewController()

        // Show action sheet
        viewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    /// Handle SmartSpectra SDK initialization and present the screening page when the button is tapped.
    internal func smartSpectraButtonTapped() {
        
        // show tutorial first time the user taps the button
        showTutorialAndAgreementIfNecessary { [weak self] in
            guard let self = self else { return }
            
            // Add code here to initialize the SmartSpectra SDK
            // Once the SDK is initialized, you can proceed with presenting the screening page.
            if UserDefaults.standard.bool(forKey: "HasAgreedToTerms")  && UserDefaults.standard.bool(forKey: "HasAgreedToPrivacyPolicy") {
                let sPage = SmartSpectra().ScreeningPage(recordButton: Model.Option.Button.Record.init(backgroundColor: UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00), titleColor: .white, borderColor: UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00), title: "Record"))
                
                // Assuming you have access to the view controller where the button is added
                let viewController = self.findViewController()
                // Check if the current view controller is embedded in a navigation controller
                if let navigationController = viewController?.navigationController {
                    navigationController.pushViewController(sPage, animated: true)
                } else {
                    // If not, present it modally
                    let nav = UINavigationController(rootViewController: sPage)
                    nav.modalPresentationStyle = .overFullScreen
                    viewController?.present(nav, animated: true)
                }
            }
        }
    }

    /// Helper method to find the view controller in the view hierarchy.
    private func findViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        return rootViewController
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImagePageViewController: UIPageViewController, UIPageViewControllerDataSource {
    var pages: [UIViewController] = []
    var onTutorialCompleted: (() -> Void)? // Closure to be called when the tutorial is completed

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self

        // Setup the pages array with image and description
        let imageNames = ["tutorial_image1", "tutorial_image2", "tutorial_image3", "tutorial_image4", "tutorial_image5", "tutorial_image6", "tutorial_image7"]
        let descriptions = [
            "Place your device running SmartSpectra on a stable surface, like a table.",
            "SmartSpectra works best when you're in a well-lit environment with natural sunlight for optimal performance.",
            "SmartSpectra works best when your face is evenly lit and does not have shadows.",
            "Avoid having bright light sources directly behind your face, such as overhead lighting.",
            "Stay still and refrain from talking while using SmartSpectra.",
            "You'll receive real-time feedback during the measurement process to assist you.",
            "Start recording with SmartSpectra upon the 'Hold Still and Record' prompt. A 30-second recording follows, and should feedback appear, comply with the prompts for an auto-restart."
        ]

        for (index, imageName) in imageNames.enumerated() {
            let vc = newViewController(imageName: imageName, description: descriptions[index])
            pages.append(vc)
        }

        if let firstViewController = pages.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            if isBeingDismissed {
                // This means the ImagePageViewController is being dismissed
                self.onTutorialCompleted?() // Invoke the completion closure after the last page transition completes
            }
        }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1
        
        if previousIndex >= 0 {
            return pages[previousIndex]
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        
        // Check if the current page is the last one
        if nextIndex >= pages.count {
            // Delay the completion callback slightly to ensure it fires after the user navigates away from the last page
            return nil
        }
        
        return pages[nextIndex]
    }

    private func newViewController(imageName: String, description: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        let imageView = UIImageView()

        // Load the image into the UIImageView
        if let image = UIImage(named: imageName, in: .module, compatibleWith: nil) {
            imageView.image = image
        } else {
            print("Failed to load image: \(imageName)")
            // Set a placeholder image if needed
        }

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(imageView)

        // Constraints for imageView to fill the view but leave space for the label overlay
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -100)
        ])

        // Create and configure the description label
        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.backgroundColor = UIColor.white.withAlphaComponent(0.9) // Solid white background for readability
        descriptionLabel.textColor = .black
        descriptionLabel.font = UIFont.systemFont(ofSize: 20) // Adjust font size as necessary
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0 // Allows label to expand for multiple lines
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(descriptionLabel)

        // Constraints for descriptionLabel to align it at the bottom
        let descriptionLabelHeight: CGFloat = 150 // Increase the height as necessary to fit the text
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor), // Align to the bottom safe area
            descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeight)
        ])
        
        let rightArrowImageView = UIImageView()
        rightArrowImageView.contentMode = .scaleAspectFit
        rightArrowImageView.tintColor = .systemBlue
        rightArrowImageView.isOpaque = true
        rightArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(rightArrowImageView)
        
        // Load the right arrow for swipe
        if let rightArrow = UIImage(systemName: imageName == "tutorial_image7" ? "arrowshape.down.fill" : "arrowshape.right.fill") {
            rightArrowImageView.image = rightArrow
        } else {
            print("Failed ot load arrow image.")
        }
        
        NSLayoutConstraint.activate([
            rightArrowImageView.heightAnchor.constraint(equalToConstant: 50),
            rightArrowImageView.widthAnchor.constraint(equalToConstant: 50),
            rightArrowImageView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -20),
            rightArrowImageView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: -20)
        ])

        return vc
    }
}

extension Image {
    init(packageResource name: String, ofType type: String) {
        #if canImport(UIKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
        #elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = NSImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(nsImage: image)
        #else
        self.init(name)
        #endif
    }
}
