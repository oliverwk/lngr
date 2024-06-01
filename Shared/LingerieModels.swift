//
//  LingerieModels.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 01/06/2024.
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
    
    public func ShowNotification() {
        logger.log("Showing the notification")
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
                    if (self.lingeries.isEmpty) {
                        MyLngr = self.lingeries[0]
                    } else {
                        MyLngr = self.lingeries[1]
                    }
                    
                    if (UserDefaults.standard.value(forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))") != nil && !( UserDefaults.standard.value(forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))") as! String == SHA256.hash(data: Data("\(self.lingeries[0])".utf8)).description )) || ProcessInfo.processInfo.arguments.contains("SendNotification") {
                        let lngrType = self.lngrsName == "lngrSlips" ? "slip" : "body"
                        
                        
                        let content = UNMutableNotificationContent()
                        content.title = "New lngr"
                        content.body = "Er is een nieuw \(lngrType) de \(MyLngr.naam) voor maar €\(MyLngr.prijs) in het \(MyLngr.kleur)"
                        content.badge = 0
                        content.userInfo["price"] = "€\(MyLngr.prijs)"
                        content.userInfo["kleurFamilies"] = MyLngr.kleurFam[0].naam
                        self.logger.log("kleurfam \(MyLngr.kleurFam, privacy: .public)")
                        content.userInfo["ImageURLS"] = MyLngr.imageUrls
                        
                        if self.lngrsName == "lngrSlips" {
                            content.categoryIdentifier = "LingeriePriceUpdate"
                        }
                        
                        let hiddenPreviewsPlaceholder = "%u new lngr available for a lower price"
                        let summaryFormat = "%u more lngrs for a lower price"
                        let lngrCategory = UNNotificationCategory(identifier: "lngr", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: hiddenPreviewsPlaceholder, categorySummaryFormat: summaryFormat, options: [])
                        UNUserNotificationCenter.current().setNotificationCategories([lngrCategory])
                        if self.lngrsName != "lngrSlips" {
                            content.categoryIdentifier = lngrCategory.identifier
                        }
                        
                        
                        
                        let url = URL(string: MyLngr.img_url_sec)!
                        
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            if (error != nil) {
                                self.logger.log("The error: \(error.debugDescription, privacy: .public)")
                            } else {
                                self.logger.log("The res: \((response as? HTTPURLResponse)!.statusCode, privacy: .public)")
                                let tmpurl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(self.lngrsName)tmp.jpg")
                                do {
                                    try data.write(to: tmpurl)
                                    content.attachments = [try UNNotificationAttachment(identifier: MyLngr.img_url_sec, url: tmpurl)]
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
                                    if ProcessInfo.processInfo.arguments.contains("SendNotification") {
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
                                    self.logger.error("There was an error with getting the notifation thumbnail: \(error.localizedDescription, privacy: .public)")
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
                    
                    if UserDefaults.standard.value(forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))") == nil || false {
                        let key = "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))"
                        UserDefaults.standard.set(SHA256.hash(data: Data("\(decodedLists[0])".utf8)).description, forKey: key)
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

enum LngrType {
    case slip
    case bra
    case body
}

struct KleurFamilie: Codable, Identifiable, CustomStringConvertible, Hashable, Equatable {
   
    public var id: String
    public var naam: String
    public var hex: String
    public var imgUrl: String
    public var URLS: String
    public var url: URL {
        return URL(string: URLS) ?? URL(string: "about:blank")!
    }
    
    
    public var description: String {
        return "{ id: \(id), naam: \(naam), hex: \(hex), img_url: \(imgUrl), url: \(url)}"
    }
    
    public var colour: Color {
        let index1 = hex.index(hex.startIndex, offsetBy: 1)
        let hexColour = hex[index1...]
        
        let indexr = hexColour.index(hexColour.startIndex, offsetBy: 2)
        let red = UInt8(hexColour[..<indexr], radix: 16)
        let indexg = hexColour.index(hexColour.startIndex, offsetBy: 4)
        let green = UInt8(hexColour[indexr..<indexg], radix: 16)
        let indexb = hexColour.index(hexColour.startIndex, offsetBy: 6)
        let blue = UInt8(hexColour[indexg..<indexb], radix: 16)
        // print("rgb \(Double(red!)) \(Double(green!)) \(Double(blue!))")
        return Color(red: Double(red!) / 255, green: Double(green!) / 255, blue: Double(blue!) / 255)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case hex
        case imgUrl = "img_url"
        case URLS = "url"
    }
}

struct Lingerie: Codable, Identifiable, CustomStringConvertible, Hashable {
    public var id: String
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    public var url: String
    public var kleur: String
    public var kleurFam: Array<KleurFamilie>
    public var description: String {
        return "{ id: \(id), naam: \(naam), prijs: \(prijs), img_url: \(img_url), img_url_sec: \(img_url_sec), imageUrls: \(imageUrls), url: \(url), kleur: \(kleur) }"
    }
    public var SecondImage: URL {
        return URL(string: img_url_sec) ?? URL(string: "about:blank")!
    }
    
    public var ImageURLS: Array<URL> {
        var ImageUrlS = [URL]()
        for url in imageUrls {
            ImageUrlS.append(URL(string: url)!)
        }
        return ImageUrlS
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case prijs
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
        case kleurFam = "kleurFamilies"
        case url
        case kleur
    }
}
