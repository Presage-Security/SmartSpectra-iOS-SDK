//
//  File.swift
//  
//
//  Created by Benyamin Mokhtarpour on 5/22/23.
//

import Foundation

extension SmartSpectra {
    
    internal func createScreeningPage(option: Model.Option.Button.Record? = nil) -> ViewController.Screening.Root {
        
        let propertyObject = RecordButtonPropertyObject.init(recordButton: option)
        let vm = ViewModel.Screening(propertyProvider: propertyObject)
        let vc = ViewController.Screening.Root(viewModel: vm)
        return vc
    }


}
