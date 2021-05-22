//
//  lngrApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import SwiftUI
import os.log

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
                        logger.notice("Found \(id, privacy: .public) for index \(i, privacy: .public)")
                        break
                    }
                    i += 1
                }
            }
        }
    }
}


