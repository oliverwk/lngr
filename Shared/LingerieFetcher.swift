//
//  LingerieFetcher.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 09/06/2024.
//

import Foundation
import CryptoKit
import SwiftUI
import os

public class LingerieFetcher: ObservableObject {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingerieFetcher"
    )
    @Published var lingeries = [Lingerie]()
    @Published var IsLoading = false
    var OriginalLingeries = [Lingerie]()
    var lngrsName: String
    var url: URL
    /// Helper function to porvide user feedback when somthing has gone wrong
    public func simpleError() {
#if os(iOS)
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.error)
#endif
    }
    
    public func simpleSuccess() {
#if os(iOS)
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.success)
#endif
    }
    
    public func ShowNotification(_ sendAnyway: Bool = false) {
        logger.log("Showing the notification")
#if os(iOS)
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                self.logger.error("The err: \(error.localizedDescription, privacy: .public)")
            }
            self.logger.log("Notifaction Authorization: \(granted, privacy: .public)")
            
            if granted {
                DispatchQueue.global(qos: .utility).async {
                    self.logger.debug("This is run on a background queue")
                    
                    var MyLngr: Lingerie
                    MyLngr = self.lingeries[0]
                    
                    let lngrhash = "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))-\(self.lngrsName)"
                    
                    if (UserDefaults.standard.value(forKey: lngrhash) != nil && !(UserDefaults.standard.value(forKey: lngrhash) as! String == SHA256.hash(data: Data("\(self.lingeries[0])".utf8)).description )) || ProcessInfo.processInfo.arguments.contains("SendNotification") || sendAnyway {
                        let lngrType = self.lngrsName == "lngrSlips" ? "slip" : "body"
                        
                        
                        let content = UNMutableNotificationContent()
                        content.title = "New lngr"
                        content.body = "Er is een nieuw \(lngrType) de \(MyLngr.naam.lowercased()) voor maar €\(MyLngr.prijs) in het \(MyLngr.kleurFam[0].naam.lowercased())"
                        content.badge = 0
                        content.userInfo["price"] = "€\(MyLngr.prijs)"
                        let jsonData = try? JSONEncoder().encode(MyLngr.kleurFam)
                        content.userInfo["kleurFamilies"] = String(data: jsonData ?? Data(), encoding: String.Encoding.utf8)
                        self.logger.log("kleurfam \(MyLngr.kleurFam, privacy: .public)")
                        content.userInfo["ImageURLS"] = MyLngr.imageUrls

//                        if self.lngrsName == "lngrSlips" {
                            content.categoryIdentifier = "LingeriePriceUpdate"
//                        }
                        
                        let hiddenPreviewsPlaceholder = "%u new lngr available for a lower price"
                        let summaryFormat = "%u more lngrs for a lower price"
                        let lngrCategory = UNNotificationCategory(identifier: "lngr", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: hiddenPreviewsPlaceholder, categorySummaryFormat: summaryFormat, options: [])
                        UNUserNotificationCenter.current().setNotificationCategories([lngrCategory])

                        
                        let url = URL(string: MyLngr.img_url_sec+"?width=500")!
                        
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            if (error != nil) {
                                self.logger.log("The error: \(error.debugDescription, privacy: .public)")
                            } else {
                                self.logger.log("The res: \((response as? HTTPURLResponse)!.statusCode, privacy: .public)")
                                let tmpurl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(self.lngrsName)tmp.jpg")
                                do {
                                    try data.write(to: tmpurl)
                                    content.attachments = [try UNNotificationAttachment(identifier: MyLngr.imageUrls[1], url: tmpurl)]
                                    content.userInfo["id"] = MyLngr.id
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
                                    if ProcessInfo.processInfo.arguments.contains("SendNotification") || sendAnyway{
                                        let nextTriggerDate = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
                                        let nextTriggerDateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextTriggerDate)
                                        trigger = UNCalendarNotificationTrigger(dateMatching: nextTriggerDateComponent, repeats: false)
                                    } else {
                                        trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
                                    }
                                    
                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger) // Schedule the notification.
                                    self.logger.log("Scheduleing Notification")
                                    center.add(request) { (error : Error?) in
                                        if let theError = error {
                                            self.logger.error("The err: \(theError.localizedDescription, privacy: .public)")
                                            // Handle any errors
                                        } else {
                                            self.logger.log("Added to the notification center")
                                        }
                                    }
                                } catch {
                                    self.logger.error("There was an error with getting the notifation thumbnail: \(error, privacy: .public)")
                                }
                            }
                        }
                        task.resume()
                    } else {
                        self.logger.log("no notifactions need to be send right now")
                    }
                }
            } else {
                self.logger.notice("There was no access granted to the notifactions")
            }
        }
#endif
    }
    
    /// Gets extra Lingerie from specifed url
    /// - Parameter url: Url to get the lngr from
    public func getExtraLngr(url: URL) {
        if !IsLoading {
            self.IsLoading = true
            self.logger.log("Making request to get extra lngr: \(url.absoluteString, privacy: .public)")
            URLSession.shared.dataTask(with: url) {(data, response, error) in
                DispatchQueue.main.async { self.IsLoading = false }
                do {
                    if let d = data {
                        let decodedLngrs = try JSONDecoder().decode([Lingerie].self, from: d)
                        self.simpleSuccess()
                        DispatchQueue.main.async {
                            self.lingeries.append(contentsOf: decodedLngrs)
                            self.OriginalLingeries.append(contentsOf: decodedLngrs)
                        }
                    } else if let error = error {
                        self.simpleError()
                        if let response = response as? HTTPURLResponse {
                            self.logger.fault("[ERROR] Er was geen data met het laden van extra lngr een url: \(url, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(String(describing :error), privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                        } else {
                            self.logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(url, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                        }
                    }
                } catch let DecodingError.dataCorrupted(context) {
                       print(context)
                   } catch let DecodingError.keyNotFound(key, context) {
                       print("Key '\(key)' not found:", context.debugDescription)
                       print("codingPath:", context.codingPath)
                   } catch let DecodingError.valueNotFound(value, context) {
                       print("Value '\(value)' not found:", context.debugDescription)
                       print("codingPath:", context.codingPath)
                   } catch let DecodingError.typeMismatch(type, context)  {
                       print("Type '\(type)' mismatch:", context.debugDescription)
                       print("codingPath:", context.codingPath)
                } catch {
                    self.simpleError()
                    if let response = response as? HTTPURLResponse {
                        self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(String(describing: error), privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    } else {
                        self.logger.fault("[ERROR] Er was een error terwijl de json werd geparsed: \(url, privacy: .public) met data \(String(decoding: data!, as: UTF8.self), privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                    }
                }
            }.resume()
        } else {
            self.logger.log("Already making a reqeust")
        }
    }
    
    init(_ url: URL, _ lngrsName: String) {
        //If you want to reset everting from spotlight use: reset()
        self.lngrsName = lngrsName
        self.url = url
        LoadLngrs(Url: url, lngrsName: lngrsName)
    }
    
    /// Loads Lingreies from the provided url an adds it to the Published properties
    ///
    /// Runs at the init of ``LingerieFetcher``
    ///
    /// - Parameters:
    ///   - Url: URL to load the data from
    ///   - lngrsName: What sort of lingerie is going to be loaded
    func LoadLngrs(Url: URL, lngrsName: String) -> Void {
        self.logger.log("Making request to: \(Url.absoluteString, privacy: .public)")
        DispatchQueue.main.async { self.IsLoading = true }
        URLSession.shared.dataTask(with: Url) {(data, response, error) in
            DispatchQueue.main.async { self.IsLoading = false }
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    DispatchQueue.main.async {
                        self.lingeries = decodedLists
                        self.OriginalLingeries = decodedLists
                        self.ShowNotification()
                    }
                    
                    let lngrHash = "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))-\(lngrsName)"
                    
                    if UserDefaults.standard.value(forKey: lngrHash) == nil || false {
                        UserDefaults.standard.set(SHA256.hash(data: Data("\(decodedLists[0])".utf8)).description, forKey: lngrHash)
                    }
                    
                    self.AddToSpotlightWithId(lngrName: lngrsName, lngrs: decodedLists)
                } else if let error = error {
                    self.simpleError()
                    
                    if let response = response as? HTTPURLResponse {
                        self.logger.fault("[ERROR] Er was geen data met het laden een url: \(Url, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    } else {
                        self.logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(Url, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                    }
                }
            } catch {
                self.simpleError()
                
                if let response = response as? HTTPURLResponse {
                    self.logger.fault("[ERROR] Er was geen data met het laden een url: \(Url, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                } else {
                    self.logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(Url, privacy: .public) met data \(String(decoding: data!, as: UTF8.self), privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                }
            }
        }.resume()
    }
}
