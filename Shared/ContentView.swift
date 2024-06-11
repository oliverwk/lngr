//
//  ContentView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 09/05/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//

import os
import Combine
import SwiftUI
import LocalAuthentication
import CoreSpotlight

struct ContentView: View {
    
    // Used for detecting when this scene is backgrounded and isn't currently visible.
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection = ""
    @State private var blurRadius: CGFloat = 50.0
    @State private var previousScene = ScenePhase.background
    private var authContext = LAContext()
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "ContentView"
    )
    
    var body: some View {
        if blurRadius == 1000.0 {
            Button("Authenticate application") {
                self.logger.debug("We gaan identitiet checken, na  druk op de knop")
                authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to go to lngr") { success, error in
                    if success {
                        self.logger.debug("Identitiet is gechecken")
                        DispatchQueue.main.async { self.blurRadius = 0.0 }
                    } else {
                        logger.log("There was an error with localAuth: \(error?.localizedDescription ?? "Failed to authenticate", privacy: .public)")
                        // Fall back to a asking for username and password.
                        DispatchQueue.main.async { self.blurRadius = 1000.0 }
                    }
                }
            }
            .buttonStyle(.bordered)
        }
      
        TabView(selection: $selection) {
            LingeriesView("https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json", "Slips", $selection)
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("Slips")
                    }
                }
                .tag("Slips")
            LingeriesView("https://raw.githubusercontent.com/oliverwk/wttpknng/master/bodys.json", "Bodys", $selection)
                .tabItem {
                    VStack {
                        Image(systemName: "rectangle.3.offgrid")
                        Text("Bodys")
                    }
                }
                .tag("Bodys")
            LingeriesView("https://raw.githubusercontent.com/oliverwk/wttpknng/master/bras.json", "Bras", $selection)
                .tabItem {
                    VStack {
                        Image(systemName: "eyes")
                        Text("Bras")
                    }
                }
                .tag("Bras")
        }.blur(radius: blurRadius)
            .onAppear {
                // MARK: - spotlight and reset logic
                let ResetEverything = UserDefaults.standard.bool(forKey: "reset_everything")
                let ResetSpotlight = UserDefaults.standard.bool(forKey: "reset_spotlight")
                logger.log("In the settings page the reset everything is: \(ResetEverything, privacy: .public) and the reset spotlight is: \(ResetSpotlight, privacy: .public)")
                if ResetEverything {
                    logger.critical("Reseting Spotlight and userdefaults")
                    let defaults = UserDefaults(suiteName: "nl.wittopkoning.lngr.lngrs")!
                    for lngrsName in ["lngrSlips", "lngrBodys"] {
                        logger.critical("Deleting: \(lngrsName, privacy: .public)IdsIndexInSpotlight")
                        defaults.removeObject(forKey: "\(lngrsName)IdsIndexInSpotlight")
                    }
                    deleteSpotlight()
                    UserDefaults.standard.set(false, forKey: "reset_spotlight")
                    UserDefaults.standard.set(false, forKey: "reset_everything")
                } else if ResetSpotlight {
                    logger.critical("Reseting Spotlight")
                    deleteSpotlight()
                    UserDefaults.standard.set(false, forKey: "reset_spotlight")
                }
                
                
                
               /* if ProcessInfo.processInfo.arguments.contains("NoAuth") {
                    DispatchQueue.main.async { self.blurRadius = 0.0 }
                } else {
                    authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to go to lngr") { success, error in
                        if success {
                            DispatchQueue.main.async { self.blurRadius = 0.0 }
                        } else {
                            logger.log("There was an error with localAuth: \(error?.localizedDescription ?? "Failed to authenticate", privacy: .public) ")
                            // Fall back to a asking for username and password.
                            DispatchQueue.main.async { self.blurRadius = 1000.0 }
                        }
                    }
                }*/
            }
        // MARK: - Blur logic
            #if os(iOS)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // go to background
                DispatchQueue.main.async { self.blurRadius = 1000.0 }
                self.logger.debug("We zijn onrecieve naar de background")
            }
            #endif
            .onChange(of: scenePhase) { newScenePhase in
                if newScenePhase == .active && !(previousScene == .inactive) {
                    self.logger.debug("We gaan identitiet checken")
                    authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to go to lngr") { success, error in
                        if success {
                            self.logger.debug("Identitiet is gechecken")
                            DispatchQueue.main.async { self.blurRadius = 0.0 }
                        } else {
                            logger.log("There was an error with localAuth: \(error?.localizedDescription ?? "Failed to authenticate", privacy: .public)")
                            // Fall back to a asking for username and password.
                            DispatchQueue.main.async { self.blurRadius = 1000.0 }
                        }
                    }
                } else if newScenePhase == .background {
                    self.logger.debug("We zijn in de achtergrond van onchange")
                    DispatchQueue.main.async { self.blurRadius = 1000.0 }
                }
                previousScene = newScenePhase
            }
        
    }
    /// Checks the settings page and if
    func deleteSpotlight() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["nl.wittopkoning.lngr"]) { error in
            if let errs = error {
                logger.fault("An error happend while reseting the spolight index: \(errs.localizedDescription, privacy: .public)")
            } else {
                logger.critical("Deleted the hole spotlight index")
            }
        }
    }
}

