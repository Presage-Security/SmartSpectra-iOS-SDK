//
//  File.swift
//
//
//  Created by Benyamin Mokhtarpour on 7/25/23.
//

import Foundation
import UIKit
import Combine
import SwiftUI

/// A custom button with predefined appearance and behavior for SmartSpectra SDK.
@available(iOS 13.0, *)
final public class SmartSpectraButton: UIButton {
    private var checkupButton: CheckupButton!
    private var infoButton: UIButton!
    public let responseSubject = PassthroughSubject<String, Never>()

    /// The container view that holds the label and image view.
    private let contentContainerView = UIView()

    /// The label displaying "Checkup" on the button.
    private let checkupLabel = UILabel()
    private var initialBackgroundColor: UIColor?
    private var initialBorderWidth: CGFloat?
    private var initialBorderColor: CGColor?
    private var initialCornerRadius: CGFloat?
    private var initialLayer: CALayer?
    private var initialFrame: CGRect?
    private let apiKey: String
    public weak var delegate: SmartSpectraDelegate?
    public var onTap: ((Bool) -> Void)?

    /// The heart image view representing the SmartSpectra action.
    private let heartImageView = UIImageView(image: UIImage(systemName: "heart.fill"))

    /// Initializes the SmartSpectraButton.
       ///
       /// - Parameter apiKey: The API key to use for SmartSpectra SDK.
       ///
       /// The button is styled with a background color of #D5E7FD, corner radius of 16, and fixed height of 90.
       /// It contains a "Checkup" label on the left side with Open-Sans font and size 15.4,
       /// and a heart icon on the right side with the system Pink color.
       ///
       /// If the height of the button is set to a value other than 90, the app will crash with a fatalError message.
       ///
       /// Usage:
       /// ```
       /// let apiKey = "your_api_key_here"
       /// let smartSpectraButton = SmartSpectraButton(apiKey: apiKey)
       /// view.addSubview(smartSpectraButton)
       /// ```
    public init(apiKey: String) {
        self.apiKey = apiKey
        super.init(frame: .zero)

        // Set background color and corner radius
        initialBackgroundColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00)
        self.backgroundColor = initialBackgroundColor
       
        // Set initial border properties
        initialBorderWidth = 4
        initialBorderColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00).cgColor
        
        self.layer.borderColor = initialBorderColor ?? UIColor.clear.cgColor
        self.layer.borderWidth = initialBorderWidth ?? 0

        // Set initial corner radius
        initialCornerRadius = 90 / 2
        self.layer.cornerRadius = initialCornerRadius ?? 16
        self.clipsToBounds = true
        // Set initial frame
        initialFrame = self.frame

//        // Check if the height is set to 90, otherwise, raise a fatal error.
//        guard self.frame.height == 90 else {
//            fatalError("SmartSpectraButton height must be 90. Do not set the height.")
//        }

        // Set up content container view
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentContainerView)
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 0

        // Set constraints for the content container view
        NSLayoutConstraint.activate([
            contentContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            contentContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            contentContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            contentContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            contentContainerView.heightAnchor.constraint(equalToConstant: 74), // Height constraint set to 74 (90 - 2 * 8 for top and bottom padding)
        ])
        contentContainerView.addSubview(stackView)

        // Set up constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        checkupButton = CheckupButton()

        // Create the "Info" button
        infoButton = UIButton()
        infoButton.backgroundColor = .white
        infoButton.setImage(UIImage(systemName: "info.circle.fill"), for: .normal)
        infoButton.imageView?.tintColor = UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00)
        // Adjust the content inset to change the image size
        let desiredImageSize = CGSize(width: 35, height: 35) // Change to your desired size
        let widthInset = (infoButton.frame.width - desiredImageSize.width) / 2
        let heightInset = (infoButton.frame.height - desiredImageSize.height) / 2
        infoButton.contentEdgeInsets = UIEdgeInsets(top: heightInset, left: widthInset, bottom: heightInset, right: widthInset)

        checkupButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(checkupButton)
        stackView.addArrangedSubview(infoButton)
        NSLayoutConstraint.activate([
            checkupButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8),
            checkupButton.heightAnchor.constraint(equalTo: stackView.heightAnchor),
        ])

        checkupButton.addTapGestureRecognizer(action: {[weak self] in
            guard let self else { return }
            self.onTap?(false)
            self.smartSpectraButtonTapped()
        })

        infoButton.addTapGestureRecognizer(action: {[weak self] in
            guard let self else { return }
            self.showActionSheet()
        })

    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if UserDefaults.standard.bool(forKey: "WalkthroughShown") == false {
                self.handleWalkTrough()
            }
        })
    }

    internal func handleWalkTrough() {
        let imagePageVC = ImagePageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        imagePageVC.onTutorialCompleted = { [weak self] in
            self?.presentUserAgreement()
        }
        findViewController()?.present(imagePageVC, animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "WalkthroughShown")
    }
    private func presentUserAgreement() {
        if !UserDefaults.standard.bool(forKey: "HasAgreedToTerms") {
            checkInternetConnectivity { [weak self] isConnected in
                DispatchQueue.main.async {
                    if isConnected {
                        let agreementViewController = ViewController.Agreement.Root()
                        let navigationController = UINavigationController(rootViewController: agreementViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        navigationController.modalTransitionStyle = .coverVertical

                        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                            rootViewController.present(navigationController, animated: true, completion: nil)
                        }
                    } else {
                        self?.showNoInternetConnectionAlert()
                    }
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
        actionSheet.addAction(UIAlertAction(title: "Terms of Service", style: .default) { _ in
            self.openSafari(withURL: "https://api.physiology.presagetech.com/termsofservice")
        })

        actionSheet.addAction(UIAlertAction(title: "Instructions for Use", style: .default) { _ in
            self.openSafari(withURL: "https://api.physiology.presagetech.com/instructions")
        })

        actionSheet.addAction(UIAlertAction(title: "Privacy Policy", style: .default) { _ in
            self.openSafari(withURL: "https://api.physiology.presagetech.com/privacypolicy")
        })

        actionSheet.addAction(UIAlertAction(title: "Contact Us", style: .default) { _ in
            self.openSafari(withURL: "https://api.physiology.presagetech.com/contact")
        })
        actionSheet.addAction(UIAlertAction(title: "Tutorial", style: .default) { _ in
            UserDefaults.standard.set(false, forKey: "WalkthroughShown")
            self.handleWalkTrough()
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
    private func smartSpectraButtonTapped() {
        // Add code here to initialize the SmartSpectra SDK
        // For example, you can use the apiKey property to pass the API key to the SDK initialization process.
        // Once the SDK is initialized, you can proceed with presenting the screening page.
        if !UserDefaults.standard.bool(forKey: "HasAgreedToTerms") {
            presentUserAgreement()
        } else {
            let smartSpectra = SmartSpectra(apiKey: apiKey)
            let sPage = smartSpectra.ScreeningPage(recordButton: Model.Option.Button.Record.init(backgroundColor: UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00), titleColor: .white, borderColor: UIColor(red: 0.94, green: 0.34, blue: 0.36, alpha: 1.00), title: "Record"))
            
            sPage.onDataPassed = {[weak self] data in
                self?.sendDataToApp(model: data)
            }
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
    
    internal func sendDataToApp(model: Model.Response.ProcessedData?) {
        let view = SmartSpectraResultView()
        let strictPulseRate = round(model?.strictPulseRate ?? 0.0)
        let strictBreathingRate = round(model?.strictBreathingRate ?? 0.0)
        let strictPulseRateInt = Int(strictPulseRate)
        let strictBreathingRateInt = Int(strictBreathingRate)
        // Determine the display text for pulse and breathing rates
        if strictPulseRateInt == 0 || strictBreathingRateInt == 0 {
                let message = "Your data was insufficient for an accurate measurement. Please move to a better-lit location, hold still, and try again. For more guidance, see the tutorial in the dropdown menu of the 'i' icon next to 'Checkup.'"
                view.updateResultLabel(with: message)
                NotificationCenter.default.post(name: Notification.Name("SmartSpecteraUpdateResultView"), object: "\(message)")
            } else {
                // If both readings are valid, format the results with BPM
                let pulseRateText = "Pulse Rate: \(strictPulseRateInt) BPM"
                let breathingRateText = "Breathing Rate: \(strictBreathingRateInt) BPM"
                view.updateResultLabel(with: "\(breathingRateText)\n\(pulseRateText)")
                NotificationCenter.default.post(name: Notification.Name("SmartSpecteraUpdateResultView"), object: "\(breathingRateText)\n\(pulseRateText)")
            }
        
    }

    /// Helper method to find the view controller in the view hierarchy.
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Prevent modifications to the backgroundColor property after initialization.
    public override var backgroundColor: UIColor? {
          get { return super.backgroundColor }
          set {
              if let initialBackgroundColor = initialBackgroundColor, newValue != initialBackgroundColor {
                  fatalError("SmartSpectraButton does not allow modifying the backgroundColor.")
              }
              super.backgroundColor = newValue
          }
      }

    /// Prevent modifications to the borderWidth property after initialization.
    public override var layer: CALayer {
        get { return super.layer }
        set {
            if let initialBorderWidth = initialBorderWidth, newValue.borderWidth != initialBorderWidth {
                fatalError("SmartSpectraButton does not allow modifying the borderWidth.")
            }
            if let initialBorderColor = initialBorderColor, newValue.borderColor != initialBorderColor {
                fatalError("SmartSpectraButton does not allow modifying the borderColor.")
            }
            if let initialCornerRadius = initialCornerRadius, newValue.cornerRadius != initialCornerRadius {
                fatalError("SmartSpectraButton does not allow modifying the cornerRadius.")
            }
        }

    }

    /// Prevent modifications to the frame property after initialization.
    public override var frame: CGRect {
        get { return super.frame }
        set {
            if let initialFrame = initialFrame, newValue != initialFrame {
                fatalError("SmartSpectraButton does not allow modifying the frame.")
            }
            super.frame = newValue
        }
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
            descriptionLabel.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor), // Align to the bottom safe area
            descriptionLabel.heightAnchor.constraint(equalToConstant: descriptionLabelHeight)
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




