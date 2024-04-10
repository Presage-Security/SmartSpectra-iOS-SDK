//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 5/22/23.
//

import Foundation
import UIKit

extension SmartSpectra {
    func ScreeningPage(recordButton: Model.Option.Button.Record? = nil) -> ViewController.Screening.Root {
        return createScreeningPage(option: recordButton)
    }
}
