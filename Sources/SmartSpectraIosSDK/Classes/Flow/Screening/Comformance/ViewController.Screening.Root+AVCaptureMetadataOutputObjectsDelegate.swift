//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/21/23.
//

import Foundation
import UIKit

extension ViewController.Screening.Root {
    func showToast(msg: String) {
        DispatchQueue.main.async {
            if self.toastView == nil {
                // Create a new instance of Common.View.Toast
                let toast = Common.View.Toast(backgroundColor: .black, textColor: .white)
                
                // Configure the toast with the provided message
                toast.setMessage(msg)
                
                // Add the toast to the view hierarchy
                toast.addToView(self.bottomOverlayView)
                
                // Set the currentToast property to the new toast instance
                self.toastView = toast
                
                // Animate the toast's appearance
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    toast.frame.size.height = 70
                }, completion: nil)
            } else {
                self.toastView?.setMessage(msg)
            }
        }
    }
}
