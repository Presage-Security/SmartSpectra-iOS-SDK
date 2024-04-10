//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 7/1/23.
//

import Foundation
import UIKit

import UIKit

class WalkthroughViewController: UIViewController {
    private lazy var overlayView: UIView? = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.frame = self.view.frame
        return view
    }()
    var descriptionLabel: UILabel?
    var viewDescriptions: [(view: UIView, description: String)] = []
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showWalkthroughIfNeeded()
    }
    
    func showWalkthroughIfNeeded() {
        let walkthroughShown = UserDefaults.standard.bool(forKey: "WalkthroughShown")
        if !walkthroughShown {
            presentWalkthrough()
            UserDefaults.standard.set(true, forKey: "WalkthroughShown")
        } else {
            self.dismiss(animated: true) 

        }
    }
    
    func presentWalkthrough() {
        self.view.addSubview(overlayView!)
        NSLayoutConstraint.activate([
            overlayView!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            overlayView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant:0),
            overlayView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            overlayView!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])

        
        showViewAtIndex(currentIndex)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        currentIndex += 1
        if currentIndex < viewDescriptions.count {
            showViewAtIndex(currentIndex)
        } else {
            dismissWalkthrough()
        }
    }
    func showViewAtIndex(_ index: Int) {
        let viewDescription = viewDescriptions[index]
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        let convertedFrame = viewDescription.view.convert(viewDescription.view.bounds, to: overlayView)
        
        let path = UIBezierPath(rect: overlayView!.bounds)
        
        // Create a rounded rectangle path instead of a simple rectangle
        let cornerRadius: CGFloat = 10.0 // You can adjust this value to control the corner curvature
        let roundedRectPath = UIBezierPath(roundedRect: convertedFrame.insetBy(dx: 0, dy: 0), cornerRadius: cornerRadius)
        
        path.append(roundedRectPath)
        
        maskLayer.path = path.cgPath
        maskLayer.fillColor = UIColor.black.cgColor
        
        overlayView?.layer.mask = maskLayer
        
        if descriptionLabel == nil {
            descriptionLabel = UILabel(frame: CGRect(x: (self.view.frame.width - 300) / 2, y: ((self.view.frame.height) / 2) - 200 , width: 300, height: 130))
            descriptionLabel?.textColor = .white
            descriptionLabel?.numberOfLines = 0
            descriptionLabel?.textAlignment = .center
            overlayView?.addSubview(descriptionLabel!)
        }
        
        descriptionLabel?.text = viewDescription.description
    }


    var page: UIViewController?
    func dismissWalkthrough() {
        overlayView?.removeFromSuperview()
        overlayView = nil
        descriptionLabel = nil
        viewDescriptions = []
        currentIndex = 0
        self.dismiss(animated: true) {
            if !UserDefaults.standard.bool(forKey: "HasAgreedToTerms") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    let agreementViewController = ViewController.Agreement.Root()
                    let navigationController = UINavigationController(rootViewController: agreementViewController)
                    navigationController.modalPresentationStyle = .pageSheet
                    navigationController.modalTransitionStyle = .coverVertical
                    

                    self.page?.present(navigationController, animated: true, completion: nil)
                })
            }
        }
    }
    
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
    // Present the walkthrough from the current root view controller
    static func presentWalkthrough(page: UIViewController, withViewsAndDescriptions viewDescriptions: [(view: UIView, description: String)]) {        
        let walkthroughVC = WalkthroughViewController()
        walkthroughVC.viewDescriptions = viewDescriptions
        walkthroughVC.modalPresentationStyle = .overFullScreen
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .fade
        walkthroughVC.page = page
        page.view.window?.layer.add(transition, forKey: kCATransition)
        page.present(walkthroughVC, animated: false, completion: nil)
    }
}

