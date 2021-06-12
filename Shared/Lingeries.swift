//
//  lngr-old.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 21/04/2021.
//

import SwiftUI
import Combine
import CoreData
import CryptoKit
import CoreSpotlight
import MobileCoreServices
import os


struct Lingeries: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let Url: String
    var title: String
    @StateObject private var github: LingerieFetcher
    @StateObject var sreachModel: lngrSreachModel
    
    
    init(Url: String, title: String, sreachModel: lngrSreachModel) {
        self.Url = Url
        self.title = title
        _github = StateObject(wrappedValue: LingerieFetcher(Url: URL(string: Url)!, lngrsName: "lngr\(title)"))
        _sreachModel = StateObject(wrappedValue: sreachModel) 
        print("sreachModel of \(title): \(sreachModel)")
    }
    let locale = Locale.current
    
    var body: some View {
        NavigationView {
            if sreachModel.IsSpotlightLink {
                LinkView(lingerie: sreachModel.lingerie!, FoundInSpotlight: true, sreachModel: sreachModel)
            } else {
                List {
                    ForEach(github.lingeries) { TheLingerie in
                        ZStack { //Dit is om de pijl weg te halen
                            NavigationLink(destination: LinkView(lingerie: TheLingerie)) {
                                EmptyView()
                            }.hidden()
                            RemoteImage(url: TheLingerie.img_url)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding(5.0)
                                .overlay(Text(TheLingerie.naam)
                                            .font(.largeTitle)
                                            .fontWeight(.heavy)
                                            .shadow(radius: 11)
                                            .foregroundColor(Color.white))
                                .overlay(Text("\(locale.currencySymbol ?? "") \(String(TheLingerie.prijs))")
                                            .font(.title)
                                            .padding(.bottom, 25.0)
                                            .shadow(radius: 11)
                                            .foregroundColor(.secondary)
                                            .frame(maxHeight: .infinity, alignment: .bottom))
                        }
                    }
                }.navigationBarTitle(Text(title))
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


public class LingerieFetcher: ObservableObject {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingerieFetcher"
    )
    @Published var lingeries = [Lingerie]()
    
    public func simpleError() {
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.error)
    }
    
    
    func index(_ lngr: Lingerie) {
        self.logger.log("[SPOTLIGHT] indexing: \(lngr.description, privacy: .public)")
        //        let attributeSet = CSSearchableItemAttributeSet(contentType: UTType)
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = lngr.naam
        attributeSet.contentDescription = "De \(lngr.naam) kost €\(lngr.prijs)"
        attributeSet.contentURL = URL(string: lngr.url)!
        attributeSet.thumbnailURL = URL(string: lngr.img_url)!
        let request = URLRequest(url:  URL(string: lngr.img_url)!)
        if let cachedResponse = URLSession.shared.configuration.urlCache?.cachedResponse(for: request), let _ = cachedResponse.response as? HTTPURLResponse {
            attributeSet.thumbnailData = cachedResponse.data
        }
        
        
        let item = CSSearchableItem(uniqueIdentifier: lngr.id, domainIdentifier: "nl.wittopkoning.lngr", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                self.logger.error("[SPOTLIGHT] [ERROR] Er was indexing error: \(error.localizedDescription, privacy: .public)")
            } else {
                self.logger.log("[SPOTLIGHT] Search item successfully indexed! \(lngr.description, privacy: .public)")
            }
        }
    }
    func DeleteSpotlight() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["nl.wittopkoning.lngr"]) { error in
            if let errs = error {
                print("errs",errs)
            }
        }
    }
    
    init(Url: URL, lngrsName: String) {
        self.logger.log("Making request with: \(Url.absoluteString, privacy: .public)")
        let testing = false
        
        URLSession.shared.dataTask(with: Url) {(data, response, error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    DispatchQueue.main.async {
                        self.lingeries = decodedLists
                    }
                    //let defaults = UserDefaults.standard
                    let defaults = UserDefaults(suiteName: "nl.wittopkoning.lngr.lngrs")!
                    do {
                        self.logger.log("[SPOTLIGHT] Setting data in UserDefaults")
                        let encoder = JSONEncoder()
                        let encoded = try encoder.encode(self.lingeries)
                        self.logger.log("Setting key from UserDefaults: \(lngrsName)")
                        if let savedHash = defaults.object(forKey: "lngrsHash") as? String {
                            let hashed = SHA256.hash(data: encoded)
                            let TheHash = hashed.compactMap { String(format: "%02x", $0) }.joined()
                            if savedHash != TheHash || testing {
                                defaults.set(encoded, forKey: lngrsName)
                                defaults.set(TheHash, forKey: "lngrsHash")
                                self.logger.log("[SPOTLIGHT] Setting in spotlight")
                                for lngr in self.lingeries {
                                    self.logger.log("[SPOTLIGHT] indexing lngr: \(lngr, privacy: .public)")
                                    self.index(lngr)
                                }
                                self.logger.log("[SPOTLIGHT] saved data in UserDefaults: \(decodedLists.count, privacy: .public)")
                            } else {
                                self.logger.log("[SPOTLIGHT] data was the same: \(savedHash, privacy: .public) == \(TheHash, privacy: .public)")
                            }
                        } else {
                            let hashed = SHA256.hash(data: encoded)
                            let TheHash = hashed.compactMap { String(format: "%02x", $0) }.joined()
                            defaults.set(encoded, forKey: lngrsName)
                            defaults.set(TheHash, forKey: "lngrsHash")
                            self.logger.log("[SPOTLIGHT] No lngrhash in UserDefaults")
                        }
                        
                    } catch {
                        self.logger.error("[SPOTLIGHT] failed to save lingeriez to user default: \(error.localizedDescription as NSObject)")
                    }
                    
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

struct Lingerie: Codable, Identifiable, CustomStringConvertible {
    public var id: String
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    public var url: String
    public var description: String {
        return "{ id: \(id), naam: \(naam), prijs: \(prijs), img_url: \(img_url), img_url_sec: \(img_url_sec), imageUrls: \(imageUrls), url: \(url) }"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case prijs
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
        case url
    }
}
