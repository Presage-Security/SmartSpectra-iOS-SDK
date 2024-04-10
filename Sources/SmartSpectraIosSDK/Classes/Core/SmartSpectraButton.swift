//
//  File.swift
//
//
//  Created by Benyamin Mokhtarpour on 7/25/23.
//

import Foundation
import UIKit
import Combine

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
        var viewDescriptions: [(view: UIView, description: String)] = [
                (view: infoButton, description: "This is the first view."),
                (view: checkupButton, description: "This is the second view.")
            ]
        if let viewController = self.superview?.viewController {
            for subview in viewController.view.subviews {
                if subview is SmartSpectraResultView {
                    viewDescriptions.append((view: subview, description: "This is the third view."))
                }
            }
        }

        let viewController = self.findViewController() ?? self.superview?.viewController ?? UIViewController()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            WalkthroughViewController.presentWalkthrough(page: viewController, withViewsAndDescriptions: viewDescriptions)

        })
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

        actionSheet.addAction(UIAlertAction(title: "Instructions of Use", style: .default) { _ in
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
    
    internal func sendDataToApp(model: Model.Response.ProcessedData?) {
        let view = SmartSpectraResultView()
        let hrRound = round(model?.hr ?? 0.0)
        let rrRound = round(model?.rr ?? 0.0)
        let hrRoundInt = Int(hrRound)
        let rrRoundInt = Int(rrRound)
        view.updateResultLabel(with: "\(hrRoundInt) /  \(rrRoundInt)")
        delegate?.passProcessedView(view)
        NotificationCenter.default.post(name: Notification.Name("SmartSpecteraUpdateResultView"), object: "\(hrRoundInt) /  \(rrRoundInt)")
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

