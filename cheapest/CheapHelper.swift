//
//  CheapHelper.swift
//  cheapest
//
//  Created by Maarten Wittop Koning on 15/05/2021.
//

import Intents

public struct IntentHelper {
    static func getCheapestIntent(for sort: Lingeries) -> CheapestIntent {
        let intent = CheapestIntent()
        intent.sort = sort
        return intent
    }
    
    public static func donateCheapestIntent(for sort: Lingeries) {
        let intent = IntentHelper.getCheapestIntent(for: sort)
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            if let error = error {
                print("\n Error: \(error.localizedDescription))")
            } else {
                print("\n Donated CreateExpenseIntent")
            }
        }
    }
}
