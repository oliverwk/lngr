//
//  lngrApp.swift
//  OpenLocker WatchKit Extension
//
//  Created by Olivier Wittop Koning on 11/09/2021.
//

import SwiftUI

@main
struct lngrApp: App {
    @State var rndint: Int = 0
    @State var openingWidget = false
    @SceneBuilder var body: some Scene {
        WindowGroup {
            VStack {
                if openingWidget {
                    VStack {
                        Text("\(qoutes[rndint][0])")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.pink)
                            .padding(4.0)
                        Text("\(qoutes[rndint][1])")
                            .font(.caption)
                            .padding(3.0)
                    }
                } else {
                    ContentView()
                }
            }
            .onOpenURL { url in
                if url.scheme == "stoic-widget" {
                    self.openingWidget = true
                    if #available(watchOS 9.0, *) {
                        self.rndint = Int(url.absoluteString.split(separator: "://")[1]) ?? 0
                    } else {
                        self.rndint = Int(url.host ?? "0") ?? 0
                    }
                }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "LockerAlerts")
    }
}
