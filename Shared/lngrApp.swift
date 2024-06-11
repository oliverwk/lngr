//
//  lngrApp.swift
//  Shared
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

#if os(iOS)
import MobileCoreServices
#endif
import BackgroundTasks
import CoreSpotlight
import Foundation
import SwiftUI
import os


@main
struct lngrApp: App {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "lngrApp"
    )
    #if os(iOS)
    private var backgroundSupport = BackgroundSupport()
    #endif
    @State private var openingWidget = false
    @State private var rndint: Int = 0
    
    var body: some Scene {
        WindowGroup {
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
                    .onOpenURL { url in
                        #if os(iOS)
                        if url.scheme == "vacinn-widget" {
                            self.logger.log("Opening: \"https://coronadashboard.rijksoverheid.nl/landelijk/vaccinaties\" beacuse the url scheme was: vacinn-widget")
                            if let theUrl = URL(string: "https://coronadashboard.rijksoverheid.nl/landelijk/vaccinaties") {
                                UIApplication.shared.open(theUrl)
                            }
                        }
                        #endif
                        if url.scheme == "stoic-widget" {
                            openingWidget = true
                            self.rndint = Int(url.absoluteString.split(separator: "://")[1]) ?? 0
                        }
                    }
                #if os(iOS)
                    .onAppear {
                        BGTaskScheduler.shared.register(forTaskWithIdentifier: "nl.wittopkoning.lngr.GetNewLngrTask", using: nil) { (task) in
                            backgroundSupport.handleAppRefreshTask(task: task as! BGAppRefreshTask)
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        backgroundSupport.scheduleAppRefresh()
                    }
                #endif
            }
           
        }
    }
}
