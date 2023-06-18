//
//  BackgroundSupport.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 30/06/2022.
//
import os
import SwiftUI
import CryptoKit
import Foundation
import BackgroundTasks


struct RefreshAppContentsOperation {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "RefreshAppContentsOperation"
    )
    
    static let urlSessionLngr = URLSession(configuration: .default)
    static let urlSessionTumb = URLSession(configuration: .default)
    static let urlSessionpi = URLSession(configuration: .default)

    func cancel() {
        RefreshAppContentsOperation.urlSessionLngr.invalidateAndCancel()
        RefreshAppContentsOperation.urlSessionTumb.invalidateAndCancel()
        RefreshAppContentsOperation.urlSessionpi.invalidateAndCancel()
        return
    }
    
    func testBackgroundFreq() async {
        logger.log("Making request to the pi to test if this works")
        let someString = "{\"naam\": \"Olivier\",\"e_mail\": \"oli4wk@gmail.com\", \"bericht\": \"Er is een verzoek gekomen vanaf jouw iphone vanaf de lngr app. De achtergrond werkt daar echt\"}"
        do {
            var request = URLRequest(url: URL(string: "https://send.wttp.workers.dev/send_mail")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = Data(someString.utf8)
            let (data, _) = try await RefreshAppContentsOperation.urlSessionpi.upload(for: request, from: Data(someString.utf8))
            logger.log("returnJson: \(String(decoding: data, as: UTF8.self), privacy: .public)")
        } catch {
            logger.fault("[ERROR] Er was een error bij het laden van de pi test req Met de error: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func start(_ task: BGAppRefreshTask) -> Void {
        Task {
            logger.log("started the oparation")
            let lngrBody = await loadItems(URL(string: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")!)
            let lngrSlip = await loadItems(URL(string: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/bodys.json")!)
            logger.log("Got both the lngrs, now showing the message")
            await ShowNotification(lngrSlip[0], .slip)
            await ShowNotification(lngrBody[0], .body)
            await testBackgroundFreq()
            logger.log("Showed both the notifications")
            
            
            task.setTaskCompleted(success: true)
        }
    }
    
    public func ShowNotification(_ lngr: Lingerie, _ lngrType: LngrType) async {
        logger.log("Showing the notification")
        let center = UNUserNotificationCenter.current()
        var granted = false
        
        do {
            granted = try await center.requestAuthorization(options: [.alert, .badge])
        } catch {
            logger.error("The error with notifaction Authorization: \(error.localizedDescription, privacy: .public)")
        }
        
        logger.log("Notifaction Authorization: \(granted, privacy: .public)")
        
        if granted {
            // Check if this have chagend from yesterday
            let lngrHash = UserDefaults.standard.value(forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))")
            if (lngrHash != nil && (lngrHash as! String) != SHA256.hash(data: Data("\(lngr)".utf8)).description) || ProcessInfo.processInfo.arguments.contains("SendNotification") {
                let lngrTypeName = lngrType == .slip ? "slip" : "body"
                
                let content = UNMutableNotificationContent()
                content.title = "New lngr"
                content.body = "Er is een nieuw \(lngrTypeName) de \(lngr.naam) voor maar €\(lngr.prijs) in het \(lngr.kleur)"
                content.badge = 0
                content.userInfo["price"] = "€\(lngr.prijs)"
                content.userInfo["kleurFamilies"] = lngr.kleurFam
                logger.log("kleurfam \(lngr.kleurFam, privacy: .public)")
                content.userInfo["ImageURLS"] = lngr.imageUrls
                if lngrType == .slip {
                    content.categoryIdentifier = "LingeriePriceUpdate"
                }
                
                let hiddenPreviewsPlaceholder = "%u new lngr available for a lower price"
                let summaryFormat = "%u more lngrs for a lower price"
                let lngrCategory = UNNotificationCategory(identifier: "lngr", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: hiddenPreviewsPlaceholder, categorySummaryFormat: summaryFormat, options: [])
                UNUserNotificationCenter.current().setNotificationCategories([lngrCategory])
                if lngrType != .slip {
                    content.categoryIdentifier = lngrCategory.identifier
                }
                
                
                let url = URL(string: lngr.img_url_sec)!
                var data: Data
                var res: URLResponse
                do {
                    (data, res) = try await RefreshAppContentsOperation.urlSessionTumb.data(from: url)
                } catch {
                    logger.log("The error: \(error.localizedDescription, privacy: .public)")
                    data = Data()
                    return
                }
                
                logger.log("The res: \((res as? HTTPURLResponse)!.statusCode, privacy: .public)")
                let tmpurl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(lngrTypeName)tmp.jpg")
                do {
                    try data.write(to: tmpurl)
                    content.attachments = [try UNNotificationAttachment(identifier: lngr.img_url_sec, url: tmpurl)]
                    content.userInfo["id"] = lngr.id
                    content.userInfo["notiImage"] = data
                    content.sound = .none
                    
                    var dateInfo = DateComponents()
                    dateInfo.day =  Calendar.current.component(.day, from: Date())+1
                    dateInfo.month = Calendar.current.component(.month, from: Date())
                    dateInfo.year = Calendar.current.component(.year, from: Date())
                    dateInfo.hour = 7
                    dateInfo.minute = 55
                    // Deliver the notification in 30 seconds.
                    var trigger: UNCalendarNotificationTrigger
                    if ProcessInfo.processInfo.arguments.contains("SendNotification") {
                        let nextTriggerDate = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
                        let nextTriggerDateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextTriggerDate)
                        trigger = UNCalendarNotificationTrigger(dateMatching: nextTriggerDateComponent, repeats: false)
                    } else {
                        trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
                    }
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger) // Schedule the notification.
                    logger.log("Scheduleing Notification")
                    
                    do {
                        try await center.add(request)
                        self.logger.log("Added to the notification center")
                    } catch {
                        logger.error("There was an error with sending the notification: \(error.localizedDescription, privacy: .public)")
                    }
                    
                    
                } catch {
                    logger.log("there was an error with the notification tumbnail an notification self \(error.localizedDescription, privacy: .public)")
                }
                
            } else {
                logger.log("no notifactions needs to be send right now")
            }
            
        } else {
            logger.notice("There was no access granted to the notifactions")
        }
    }
    
    func loadItems(_ url: URL) async -> [Lingerie] {
        logger.log("Making request to get  lngr: \(url.absoluteString, privacy: .public)")
        var lngr = [Lingerie]()
        
        do {
            let (data, _) = try await RefreshAppContentsOperation.urlSessionLngr.data(from: url)
            lngr = try JSONDecoder().decode([Lingerie].self, from: data)
        } catch {
            logger.fault("[ERROR] Er was een error bij het laden van: \(url, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
        }
        
        return lngr
    }
    
    
}
// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"nl.wittopkoning.lngr.GetNewLngrTask"]

struct BackgroundSupport {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "BackgroundSupport"
    )
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "nl.wittopkoning.lngr.GetNewLngrTask")
        // Fetch tommorw at 7:30 so it is ready at 8 a.m.
        let tom = Calendar.current.date(byAdding: .day, value: 0, to: Date())! //TODO maak dit 1
        let morgenAchtUur = Calendar.current.date(bySettingHour: 8, minute: 30, second: 00, of: tom)!
        request.earliestBeginDate = morgenAchtUur
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.log("We hebben summit van de background")
        } catch {
            logger.log("Could not schedule app refresh: \(error, privacy: .public)")
            logger.log("Could not schedule app refresh")
        }
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        logger.log("scheduleing a new refresh")
        scheduleAppRefresh()
        
        // Create an operation that performs the main part of the background task.
        let operation = RefreshAppContentsOperation()
        
        // Provide the background task with an expiration handler that cancels the operation.
        task.expirationHandler = {
            operation.cancel()
            task.setTaskCompleted(success: false)
        }
        
        logger.log("starting the oparation")
        operation.start(task)
        
    }
    
}
