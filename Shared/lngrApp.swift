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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
            self.logger.notice("[SPOTLIGHT] Found identifier \(id, privacy: .public)")
            do {
                if let savedlngr = defaults.object(forKey: "lngrs") as? Data {
                    let decoder = JSONDecoder()
                    if let loadedLngr = try? decoder.decode(Lingerie.self, from: savedlngr) {
                        var i = 0
                        self.logger.log("[SPOTLIGHT] Is loadedLngr an array: \(loadedLngr[0], privacy: .public), hopelijk is dit een id: \(loadedLngr[0].id, privacy: .public)")
                        for lngr in loadedLngr {
                            if lngr.id == id {
                                self.logger.log("[SPOTLIGHT] Found \(id, privacy: .public) for index \(i, privacy: .public)")
                                break
                            }
                            i += 1
                        }
                    }
                }
            } catch {
                    self.logger.log("Failed to convert lngr to Data : \(error.localizedDescription)")
            }
            
            /*if let savedLingerie = defaults.object(forKey: "lngrs") as? [Lingerie] {
                var i = 0
                self.logger.log("[SPOTLIGHT] Is savedLingerie an array: \(savedLingerie[0], privacy: .public), hopelijk is dit een id: \(savedLingerie[0].id, privacy: .public)")
                for lngr in savedLingerie {
                    if lngr.id == id {
                        self.logger.notice("[SPOTLIGHT] Found \(id, privacy: .public) for index \(i, privacy: .public)")
                        break
                    }
                    i += 1
                }
            }*/
        }
    }
}


import Foundation

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
