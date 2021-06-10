//
//  lngrApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import MobileCoreServices
import CoreSpotlight
import SwiftUI
import os

@main
struct lngrApp: App {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "lngrApp"
    )
    @ObservedObject var sreachModel = lngrSreachModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sreachModel)
                .onContinueUserActivity(CSSearchableItemActionType, perform: handleSpotlight)
                .onOpenURL { url in
                    if url.scheme == "vacinn-widget" {
                        self.logger.log("Opening: \"https://coronadashboard.government.nl/landelijk/vaccinaties\" beacuse the url scheme was: vacinn-widget")
                        if let theUrl = URL(string: "https://coronadashboard.government.nl/landelijk/vaccinaties") {
                            UIApplication.shared.open(theUrl)
                        }
                    }
                }
        }
    }
    
    func handleSpotlight(_ userActivity: NSUserActivity) {
        self.logger.log("[SPOTLIGHT] Opend a spotlight link")
        let defaults = UserDefaults.standard
        if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            self.logger.log("[SPOTLIGHT] Found identifier \(id, privacy: .public)")
            
            if let savedlngr = defaults.object(forKey: "lngrs") as? Data {
                
                if let loadedLngr = try? JSONDecoder().decode([Lingerie].self, from: savedlngr) {
//                    var i = 0
                    self.logger.log("[SPOTLIGHT] Is loadedLngr an array: \(loadedLngr[0], privacy: .public), hopelijk is dit een id: \(loadedLngr[0].id, privacy: .public)")
                    for theLngr in loadedLngr {
                        if theLngr.id == id {
//                            self.logger.log("[SPOTLIGHT] Found \(id, privacy: .public) for index \(i, privacy: .public)")
                            self.logger.log("[SPOTLIGHT] Found \(id, privacy: .public) with name \(theLngr.naam, privacy: .public)")
                            sreachModel.FoundSpotlightlink(lngr: theLngr)
                        }
//                        i += 1
                    }
                }
            } else {
                self.logger.log("Failed to get lngr from UserDefaults")
            }
        }
    }
}
