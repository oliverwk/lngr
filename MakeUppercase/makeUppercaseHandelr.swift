//
//  makeUppercaseHandelr.swift
//  sock
//
//  Created by Maarten Wittop Koning on 21/08/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//

import Foundation

import Intents

class MakeUppercaseIntentHandler: NSObject, MakeUppercaseIntentHandling {
    
    // To conform to MakeUppercaseIntentHandling, we need to resolve each parameter before handling the intent
    func resolveText(for intent: MakeUppercaseIntent, with completion: @escaping (MakeUppercaseTextResolutionResult) -> Void) {
        // Each parameter is an optional. We can do any neccessary validations at this stage and throw errors if required
        if let text = intent.text, !text.isEmpty {
            completion(MakeUppercaseTextResolutionResult.success(with: text))
        } else {
            // This 'noText' code is defined in the Intent Definition file
            completion(MakeUppercaseTextResolutionResult.unsupported(forReason: .noText))
        }
    }
    
    func handle(intent: MakeUppercaseIntent, completion: @escaping (MakeUppercaseIntentResponse) -> Void) {
        if let inputText = intent.text {
            let uppercaseText = inputText.uppercased()
            completion(MakeUppercaseIntentResponse.success(result: uppercaseText))
        } else {
            // This text would show in the Shortcuts app if 'inputText' has no value
            completion(MakeUppercaseIntentResponse.failure(error: "The entered text was invalid"))
        }
    }
}
