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
    @State private var selection = 0
    @State private var blurRadius: CGFloat = 50.0
    private var authContext = LAContext()
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "ContentView"
    )
    
    var body: some View {
        TabView(selection: $selection){
            LingeriesView("https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json", "Slips")
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("Slips")
                    }
                }
                .tag(0)
            LingeriesView("https://raw.githubusercontent.com/oliverwk/wttpknng/master/bodys.json", "Bodys")
                .tabItem {
                    VStack {
                        Image(systemName: "rectangle.3.offgrid")
                        Text("Bodys")
                    }
                }
                .tag(1)
        }.blur(radius: blurRadius).onAppear {
            // Check settings page
            func deleteSpotlight() {
                CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["nl.wittopkoning.lngr"]) { error in
                    if let errs = error {
                        logger.fault("An error happend while reseting the spolight index: \(errs.localizedDescription, privacy: .public)")
                    }
                }
            }
            
            let ResetEverything = UserDefaults.standard.bool(forKey: "reset_everything")
            let ResetSpotlight = UserDefaults.standard.bool(forKey: "reset_spotlight")
            logger.log("In the settings page the reset everything is: \(ResetEverything) and the reset spotlight is: \(ResetSpotlight)")
            if ResetEverything {
                logger.critical("Reseting Spotlight and userdefaults")
                let defaults = UserDefaults(suiteName: "nl.wittopkoning.lngr.lngrs")!
                for lngrsName in ["lngrSlips", "lngrBodys"] {
                    logger.log("Deleting: \(lngrsName)IdsIndexInSpotlight")
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
            
            let reason = "Authenticate to go to lngr"
            if ProcessInfo.processInfo.arguments.contains("NoAuth") {
                DispatchQueue.main.async { self.blurRadius = 0.0 }
            } else {
                authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                    if success {
                        DispatchQueue.main.async { self.blurRadius = 0.0 }
                    } else {
                        logger.log("There was an error with localAuth: \(error?.localizedDescription ?? "Failed to authenticate")")
                        // Fall back to a asking for username and password.
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            DispatchQueue.main.async { self.blurRadius = 100.0 }
        }
        .onChange(of: scenePhase) { newScenePhase in
            if newScenePhase == .active {
                DispatchQueue.main.async { self.blurRadius = 0.0 }
            }
        }
    }
}

