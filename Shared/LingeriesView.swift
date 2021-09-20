//
//  LingeriesView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 21/04/2021.
//

import SwiftUI
import Combine
import CoreSpotlight
import CryptoKit
#if os(iOS)
import MobileCoreServices
#endif
import os


struct LingeriesView: View {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingeriesView"
    )
    let Url: String
    var title: String
    @State private var StopIndex = 34
    @StateObject private var lngrs: LingerieFetcher
    @State var LingerieID: String?
    
    init(_ Url: String, _ title: String) {
        self.Url = Url
        self.title = title
        _lngrs = StateObject(wrappedValue: LingerieFetcher(URL(string: Url)!, "lngr\(title)"))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(lngrs.lingeries) { TheLingerie in
                    ZStack {
                        NavigationLink(destination: LingerieView(lingerie: TheLingerie), tag: TheLingerie.id, selection: $LingerieID) {
                            lngrRow(TheLingerie: TheLingerie).onAppear {
                                self.StopIndex = lngrs.lingeries.count - 1
                                if lngrs.lingeries.count > 0 {
                                    logger.log("Getting lngr: \(lngrs.lingeries.firstIndex(where: { $0.id == TheLingerie.id })! == StopIndex) index: \(lngrs.lingeries.firstIndex(where: { $0.id == TheLingerie.id })!) op \(lngrs.lingeries.count), naam: \(TheLingerie.naam, privacy: .public)")
                                    if lngrs.lingeries.firstIndex(where: { $0.id == TheLingerie.id })! == StopIndex {
                                        logger.log("Getting extra lngr \(StopIndex + 20)")
                                        lngrs.getExtraLngr(url: URL(string: "https://lngr.ml/api?count=\(StopIndex + 20)")!)
                                    }
                                }
                            }
                        }

                    }
                }
                HStack(alignment: .center, spacing: 0, content: {
                    ProgressView()
                }).opacity(lngrs.IsLoading ? 1 : 0)
            }.navigationBarTitle(Text(title))
        }.navigationViewStyle(StackNavigationViewStyle()).onContinueUserActivity(CSSearchableItemActionType) { userActivity in
            if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                logger.log("Received a payload via spotlight with id: \(id, privacy: .public)")
                DispatchQueue.main.async {
                    self.LingerieID = id
                }
            } else {
                logger.critical("No CSSearchableItemActivityIdentifier found in spotlight")
            }
        }
        .onAppear {
            lngrs.ShowNotification()
        }
    }
}


public class LingerieFetcher: ObservableObject {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingerieFetcher"
    )
    @Published var lingeries = [Lingerie]()
    @Published var IsLoading = false
    private var lngrsName: String
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
            
            if granted {
                DispatchQueue.global(qos: .utility).async {
                    print("This is run on a background queue")

                    self.logger.log("Notifaction Authorization: \(granted, privacy: .public)")
                    if (UserDefaults.standard.value(forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))") != nil && !( UserDefaults.standard.value(forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))") as! String == SHA256.hash(data: Data("\(self.lingeries[0])".utf8)).description )) {
                        let lngrType = self.lngrsName == "Slips" ? "slip" : "body"
                        var MyLngr: Lingerie
                        if (self.lingeries.isEmpty) {
                            self.LoadLngrs(Url: URL(string: self.lngrsName == "Slips" ? "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json": "https://raw.githubusercontent.com/oliverwk/wttpknng/master/bodys.json")!, lngrsName: self.lngrsName)
                            MyLngr = self.lingeries[0]
                        } else {
                            MyLngr = self.lingeries[0]
                        }
                        
                        let content = UNMutableNotificationContent()
                        content.title = "New lngr"
                        content.body = "Er is een nieuw \(lngrType) de \(MyLngr.naam) voor maar €\(MyLngr.prijs) in het \(MyLngr.kleur)"
                        // content.badge = 1
                        
                        let url = URL(string: MyLngr.img_url_sec)!

                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            if (error != nil) {
                                self.logger.log("The error: \(error.debugDescription, privacy: .public)")
                            } else {
                                self.logger.log("The res: \(response.debugDescription, privacy: .public)")
                                let tmpurl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp.jpg")
                                do {
                                    try data.write(to: tmpurl)
                                    content.attachments = [try UNNotificationAttachment(identifier: MyLngr.img_url_sec, url: tmpurl)]
                                    content.userInfo = ["id": MyLngr.id]
                                    content.sound = .none
                                
                                    var dateInfo = DateComponents()
                                    dateInfo.day =  Calendar.current.component(.day, from: Date())+1
                                    dateInfo.month = Calendar.current.component(.month, from: Date())
                                    dateInfo.year = Calendar.current.component(.year, from: Date())
                                    dateInfo.hour = 7
                                    dateInfo.minute = 55
                                       
                                    // Deliver the notification in 30 seconds.
                                    // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
                                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
                                    
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
                        self.logger.notice("There was no access granted to the notifactions")
                    }
                }
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
                            self.lingeries = decodedLngrs
                        }
                    } else if let error = error {
                        self.simpleError()
                        if let response = response as? HTTPURLResponse {
                            self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                        } else {
                            self.logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(url, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                        }
                    }
                } catch {
                    self.simpleError()
                    if let response = response as? HTTPURLResponse {
                        self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
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
        self.IsLoading = true
        URLSession.shared.dataTask(with: Url) {(data, response, error) in
            DispatchQueue.main.async { self.IsLoading = false }
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    DispatchQueue.main.async {
                        self.lingeries = decodedLists
                    }
                    
                    if UserDefaults.standard.value(forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))") == nil {
                        UserDefaults.standard.set(SHA256.hash(data: Data("\(self.lingeries[0])".utf8)).description, forKey: "LngrHash\(Calendar.current.component(.day, from: Date()))-\(Calendar.current.component(.month, from: Date()))")
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

struct Lingerie: Codable, Identifiable, CustomStringConvertible, Hashable {
    public var id: String
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    public var url: String
    public var kleur: String
    public var description: String {
        return "{ id: \(id), naam: \(naam), prijs: \(prijs), img_url: \(img_url), img_url_sec: \(img_url_sec), imageUrls: \(imageUrls), url: \(url), kleur: \(kleur) }"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case prijs
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
        case url
        case kleur
    }
}
