//
//  lngrApp.swift
//  OpenLocker WatchKit Extension
//
//  Created by Olivier Wittop Koning on 11/09/2021.
//

import SwiftUI

@main
struct lngrApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "LockerAlerts")
    }
}
