//
//  lngr-old.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 21/04/2021.
//

import SwiftUI
import Combine
import CoreSpotlight
import MobileCoreServices
import os.log

struct Lingeries: View {
    let Url: String
    var title: String
    @StateObject private var github: LingerieFetcher
    
    init(Url: String, title: String) {
        self.Url = Url
        self.title = title
        _github = StateObject(wrappedValue: LingerieFetcher(Url: URL(string: Url)!) )
    }
    let locale = Locale.current
    
    var body: some View {
        NavigationView {
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
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


public class LingerieFetcher: ObservableObject {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingerieFetcher"
    )
    @Published var lingeries = [Lingerie]()
    
    public func simpleError() {
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.error)
    }
    public func index(index: Int) {
        let lingerie = self.lingeries[index]

        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = lingerie.naam
        attributeSet.contentDescription = "De \(lingerie.naam) kost \(lingerie.prijs)"

        let item = CSSearchableItem(uniqueIdentifier: lingerie.id, domainIdentifier: "nl.wittopkoning.lngr", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems(lingerie.id) { error in
            if let error = error {
                logger.error("[ERROR] Er was indexing error: \(error.localizedDescription, privacy: .public)")
            } else {
                logger.notice("Search item successfully indexed! \(lingerie, privacy: .public)")
            }
        }
    }
    
    init(Url: URL) {
        URLSession.shared.dataTask(with: Url) {(data, response, error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    DispatchQueue.main.async {
                        self.lingeries = decodedLists
                    }
                    let defaults = UserDefaults.standard
                    if let savedLingerie = defaults.object(forKey: "id") as? [String] {
                        lingeriez = savedLingerie
                    }
                    logger.notice("savedLingerie: \(savedLingerie, privacy: .public)")
                } else {
                    self.simpleError()
                    logger.error("[ERROR] Er was geen data met het laden een url: \(String(Url)) en met response: \(response, privacy: .public) Met de error: \(error)")
                }
            } catch {
                self.simpleError()
                logger.error("[ERROR] Er was een terwijl de json werd geparsed: \(String(Url)) en met response: \(response, privacy: .public) en met data \(data) Met de error: \(error)")
            }
        }.resume()
    }
}

struct Lingerie: Codable, Identifiable {
    public var id = String
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case prijs
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
    }
}
