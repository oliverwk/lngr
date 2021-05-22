//
//  lngrApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import SwiftUI

@main
struct lngrApp: App {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "lngrApp"
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlight)
        }
    }
    
    func handleSpotlight(_ userActivity: NSUserActivity) {
        if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            logger.notice("Found identifier \(id)")
            if let savedLingerie = defaults.object(forKey: "id") as? [String] {
                var i = 0
                for lngr in savedLingerie {
                    if id == lngr.id {
                        logger.notice("Found \(id) for index \(i)")
                        break
                    }
                    i += 1
                }
            }
        }
    }
}


