import UIKit

class SmartSpectra {
    internal let apiKey: String

    init(apiKey: String) {
        guard !apiKey.isEmpty else {
            fatalError("SHOULD PROVIDE AN API KEY TO USE SMART SPECTRA") // Check if the provided API key is empty. If empty, terminate the program with a fatal error message.
        }
        
        self.apiKey = apiKey // Store the provided API key in the apiKey constant.
        Service.Keys.API_KEY.setAPIKey(apiKey) // Set the API key in the Service.Keys.API_KEY enum.
    }
}
