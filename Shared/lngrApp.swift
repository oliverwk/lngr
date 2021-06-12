//
//  lngrApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import Foundation
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
//        let defaults = UserDefaults.standard
        let defaults = UserDefaults(suiteName: "nl.wittopkoning.lngr.lngrs")!
        self.logger.log("userInfo: \(userActivity.userInfo.debugDescription, privacy: .public)")
        if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            self.logger.log("[SPOTLIGHT] Found identifier \(id, privacy: .public)")
            for lng in ["lngrSlips", "lngrBodys"] {
                if let savedlngr = defaults.data(forKey: lng) as Data? {
                    self.logger.log("savedlngr: \(savedlngr, privacy: .public)")
                    if let loadedLngr = try? JSONDecoder().decode([Lingerie].self, from: savedlngr) {
                        self.logger.log("[SPOTLIGHT] Is loadedLngr an array: \(loadedLngr[0], privacy: .public), hopelijk is dit een id: \(loadedLngr[0].id, privacy: .public)")
                        for theLngr in loadedLngr {
                            if theLngr.id == id {
                                self.logger.log("[SPOTLIGHT] Found \(id, privacy: .public) with name \(theLngr.naam, privacy: .public)")
                                sreachModel.FoundSpotlightlink(lngr: theLngr)
                            }
                        }
                    } else {
                        self.logger.fault("Failed to parse the json from UserDefaults")
                    }
                } else {
                    self.logger.fault("Failed to get lngr from UserDefaults")
                }
            }
        } else {
            self.logger.fault("Failed to get lngr id from the spotlight link")
        }
    }
}
