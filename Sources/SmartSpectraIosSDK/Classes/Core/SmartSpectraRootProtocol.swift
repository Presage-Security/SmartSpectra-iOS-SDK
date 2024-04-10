//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 6/28/23.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
public protocol SmartSpectraDelegate: AnyObject {
    func passProcessedView(_ view: SmartSpectraResultView)
}
