//
//  lngr-old.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 21/04/2021.
//

import SwiftUI
import Combine


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
    @Published var lingeries = [Lingerie]()
    
    public func simpleError() {
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.error)
    }
    
    init(Url: URL) {
        URLSession.shared.dataTask(with: Url) {(data, response, error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    DispatchQueue.main.async {
                        self.lingeries = decodedLists
                    }
                } else {
                    self.simpleError()
                    print("No Data")
                }
            } catch {
                self.simpleError()
                print("Error while decoding the json", error)
            }
        }.resume()
    }
}

struct Lingerie: Codable, Identifiable {
    public var id = UUID()
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    
    
    enum CodingKeys: String, CodingKey {
        case naam = "naam"
        case prijs = "prijs"
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
    }
}
