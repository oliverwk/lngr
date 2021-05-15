//
//  CheapestHandler.swift
//  cheapest
//
//  Created by Maarten Wittop Koning on 19/03/2021.
//

import Intents

class CheapestIntentHandler: NSObject, CheapestIntentHandling {
    
    // To conform to CheapestIntentHandling, we need to resolve each parameter before handling the intent
    func resolveText(for intent: CheapestIntent, with completion: @escaping (CheapestTextResolutionResult) -> Void) {
        // Each parameter is an optional. We can do any neccessary validations at this stage and throw errors if required
        if let text = intent.text, !text.isEmpty {
            completion(CheapestTextResolutionResult.success(with: text))
        } else {
            // This 'noText' code is defined in the Intent Definition file
            completion(CheapestTextResolutionResult.unsupported(forReason: .noText))
        }
    }
    
    func handle(intent: CheapestIntent, completion: @escaping (CheapestIntentResponse) -> Void) {
        //This is were it happens
        if let inputText = intent.text {
            let uppercaseText = inputText.uppercased()
            completion(CheapestIntentResponse.success(result: uppercaseText))
        } else {
            // This text would show in the Shortcuts app if 'inputText' has no value
            completion(CheapestIntentResponse.failure(error: "The entered text was invalid"))
        }
    }
}
