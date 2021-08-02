//
//  LingeriesView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 21/04/2021.
//

import SwiftUI
import Combine
import CoreSpotlight
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
    @StateObject private var github: LingerieFetcher
    @State var LingerieID: String?
    
    init(_ Url: String, _ title: String) {
        self.Url = Url
        self.title = title
        _github = StateObject(wrappedValue: LingerieFetcher(URL(string: Url)!, "lngr\(title)"))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(github.lingeries) { TheLingerie in
                    ZStack {
                        NavigationLink(destination: LingerieView(lingerie: TheLingerie), tag: TheLingerie.id, selection: $LingerieID) {
                            lngrRow(TheLingerie: TheLingerie).onAppear {
                                self.StopIndex = github.lingeries.count - 1
                                if github.lingeries.count > 0 {
                                    logger.log("Getting lngr: \(github.lingeries.firstIndex(where: { $0.id == TheLingerie.id })! == StopIndex) index: \(github.lingeries.firstIndex(where: { $0.id == TheLingerie.id })!) op \(github.lingeries.count), naam: \(TheLingerie.naam, privacy: .public)")
                                    if github.lingeries.firstIndex(where: { $0.id == TheLingerie.id })! == StopIndex {
                                        logger.log("Getting extra lngr \(StopIndex + 20)")
                                        github.getExtraLngr(url: URL(string: "https://lngr.ml/api?count=\(StopIndex + 20)")!)
                                    }
                                }
                            }
                        }

                    }
                }
                HStack(alignment: .center, spacing: 0, content: {
                    ProgressView()
                }).opacity(github.IsLoading ? 1 : 0)
            }.navigationBarTitle(Text(title))
        }.navigationViewStyle(StackNavigationViewStyle()).onContinueUserActivity(CSSearchableItemActionType) { userActivity in
            if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                logger.log("The persistentIdentifier is: \(userActivity.persistentIdentifier.debugDescription)")
                logger.log("Received a payload via spotlight with id: \(id)")
                DispatchQueue.main.async {
                    self.LingerieID = id
                }
            } else {
                logger.critical("No CSSearchableItemActivityIdentifier found in spotlight")
            }
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
        LoadLngrs(Url: url, lngrsName: lngrsName)
    }
    
    /// Loads Lingreies from the provided url an adds it to the Published properties
    ///
    /// Runs at init of ``LingerieFetcher``
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
