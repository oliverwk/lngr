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
    
    @Environment(\.managedObjectContext) var moc
    
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingeriesView"
    )
    let Url: String
    var title: String
    let nakdname: String
    @State var urlstr: String
    @Binding var selection: String
    @State private var StopIndex = 34
    @StateObject private var lngrs: LingerieFetcher
    @State var search = ""
    @State var searchedFailed = false
    @State var PresentedLngrs: [Lingerie] = []
    @State var selectedSize = 0
    @State var selectedColour = "colors"
    @Environment(\.isSearching) var isSearching
    let cols = [GridItem(.adaptive(minimum: 325))]
    
    init(_ Url: String, _ title: String, _ nakdname: String, _ sel: Binding<String>) {
        self.Url = Url
        self.title = title
        self.nakdname = nakdname
        self.urlstr = "https://www.na-kd.com/nl/category/lingerie/\(nakdname)?sortBy=price"
        self._selection = sel
        _lngrs = StateObject(wrappedValue: LingerieFetcher(URL(string: Url)!, "lngr\(title)"))
    }
    
    /// Check at the end of the list if extra lingerie should be loaded
    func checkIfExtraLngr(TheLingerie: Lingerie) {
        if !isSearching {
            self.StopIndex = lngrs.lingeries.count - 1
            if lngrs.lingeries.count > 0 {
                let currentLngr = lngrs.lingeries.firstIndex(where: { $0.id == TheLingerie.id })
                logger.log("Getting lngr: \(currentLngr == StopIndex, privacy: .public) index: \(currentLngr.debugDescription, privacy: .public) op \(lngrs.lingeries.count, privacy: .public), naam: \(TheLingerie.naam, privacy: .public)")
                if currentLngr == StopIndex && lngrs.lingeries.count > 19 {
                    logger.log("Getting extra lngr \(StopIndex + 20)")
                    lngrs.getExtraLngr(url: "https://nkd_worker.wttp.workers.dev/?count=\(StopIndex + 20)&url=\(urlstr)".url)
                }
            }
        }
    }
    
    public func simpleSuccess() {
#if os(iOS)
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.success)
#endif
    }

    var body: some View {
        NavigationStack(path: $PresentedLngrs) {
            ScrollView {
                if searchedFailed {
                    HStack {
                        Text("Didn't find anything")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .padding()
                    }
                } else {
                    HStack(alignment: .center) {
#if os(iOS)
                        NavigationLink(destination: {
                            SearchView()
                                .environment(\.managedObjectContext, moc)
                            
                        }, label: {
                            Text("Go to       ")
                                .padding(12)
                                .background(.thickMaterial)
                                .cornerRadius(10)
                        })
#endif
                        Picker("Select a size filter", selection: $selectedSize) {
                            ForEach([0, 32,34,36,38,40,42,44], id: \.self) {
                                Text("EU\($0)")
                            }
                        }.pickerStyle(.menu)
                            .padding(5)
                            .background(.thickMaterial)
                            .cornerRadius(10)
                        
                        Picker("Select a colour filter", selection: $selectedColour) {
                            ForEach(["colors","Black","Red","Green","Blue","Grey","Brown","Pink","White","Beige","Leopard","Offwhite","Burgundy","Yellow","Purple","Multicolor","Navy"], id: \.self) {
                                Text("\($0)")
                            }
                        }.pickerStyle(.menu)
                            .padding(5)
                            .background(.thickMaterial)
                            .cornerRadius(10)
                    }
                    #if os(macOS)
                    .padding(10)
                    #endif
                    LazyVGrid(columns: cols, spacing: 20) {
                        ForEach(lngrs.lingeries) { TheLingerie in
                            NavigationLink(value: TheLingerie) {
                                lngrRow(TheLingerie: TheLingerie).onAppear {
                                    checkIfExtraLngr(TheLingerie: TheLingerie)
                                }.onAppear {
                                    if !UserDefaults.standard.bool(forKey: "AddedQoutesToSpotlight") {
                                        lngrs.AddQoutesToSpotlight(qoutes: qoutes)
                                        UserDefaults.standard.set(true, forKey: "AddedQoutesToSpotlight")
                                        UserDefaults(suiteName: "lngrMeIndex")?.set(lngrs.lingeries.description, forKey: "\(title)IndexLngrs")
                                    }
                                    if false {
#if os(iOS)
                                        let TheLNGR = LNGR(context: moc)
                                        TheLNGR.naam = TheLingerie.naam
                                        TheLNGR.prijs = TheLingerie.prijs
                                        TheLNGR.nkdid = TheLingerie.id
                                        TheLNGR.url = TheLingerie.url
                                        TheLNGR.kleur = TheLingerie.kleur
                                        TheLNGR.kleurFamIds = TheLingerie.kleurFamIds
                                        URLSession.shared.dataTask(with: TheLingerie.SecondImage) {(data, response, error) in
                                            if data != nil || error == nil {
                                                TheLNGR.image = data!
                                                DispatchQueue.main.async {
                                                    do {
                                                        try moc.save()
                                                    } catch {
                                                        print("[ERROR] Er een error bij het opslaan naar core data met de error: \(String(describing: error)) en de lngr: \(TheLingerie.description), \(error.localizedDescription)")
                                                    }
                                                }
                                            } else {
                                                print("was een error bij het ophalne van het iamge voor core data met de error: \(String(describing: error)) en de lngr: \(TheLingerie.description)")
                                            }
                                        }.resume()
#endif
                                    }
                                }
                            }
                        }
                    }
                    if !lngrs.IsLoading {
                        HStack(alignment: .center, spacing: 0, content: {
                            ProgressView()
                        }).opacity(lngrs.IsLoading ? 1 : 0)
                    }
                }
            }
            .navigationDestination(for: Lingerie.self) { lngr in
                LingerieView(lingerie: lngr)
            }
            
            .listStyle(.automatic)
            .refreshable {
                lngrs.lingeries = []
                lngrs.LoadLngrs(url: lngrs.url, lngrsName: lngrs.lngrsName)
                searchedFailed = false
            }
            .navigationTitle(title)
            .searchable(text: $search)
            .onChange(of: selectedSize) { newvalue in
                lngrs.lingeries = []
                var urlstr: String
                if selectedColour == "colors" && selectedSize != 0 {
                     urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?p_size_clothes=p_size_clothes%3A%3AEU+\(selectedSize)&sortBy=price"
                } else if selectedSize == 0 && selectedColour != "colors" {
                    urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?p_color_families=\(selectedColour)&sortBy=price"
                } else if selectedColour == "colors" && selectedSize == 0 {
                    urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?sortBy=price"
                } else {
                    urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?p_size_clothes=p_size_clothes%3A%3AEU+\(selectedSize)&p_color_families=\(selectedColour)&sortBy=price"
                }
                
                logger.log("Getting url with size: \(("https://nkd_worker.wttp.workers.dev/?url="+urlstr), privacy: .public)")
                lngrs.getExtraLngr(url: ("https://nkd_worker.wttp.workers.dev/?url="+urlstr).url)
            }
            .onChange(of: selectedColour) { newvalue in
                lngrs.lingeries = []
                
                if selectedSize == 0 && selectedColour != "colors" {
                    urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?p_color_families=\(selectedColour)&sortBy=price"
                } else if selectedColour == "colors" && selectedSize != 0 {
                    urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?p_size_clothes=p_size_clothes%3A%3AEU+\(selectedSize)&sortBy=price"
                } else if selectedColour == "colors" && selectedSize == 0 {
                    urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?sortBy=price"
                } else {
                    urlstr = "https://www.na-kd.com/nl/category/lingerie/\(self.nakdname)?p_size_clothes=p_size_clothes%3A%3AEU+\(selectedSize)&p_color_families=\(selectedColour)&sortBy=price"
                }
                
                logger.log("Getting url with size: \(("https://nkd_worker.wttp.workers.dev/?url="+urlstr), privacy: .public)")
                lngrs.getExtraLngr(url: ("https://nkd_worker.wttp.workers.dev/?url="+urlstr).url)
            }
            .onSubmit(of: .search) {
                logger.critical("Searching: \(search)")
                let searchedLngrs = lngrs.OriginalLingeries.filter { $0.naam.uppercased().contains(self.search.uppercased()) }
                logger.log("found lngr: \(searchedLngrs, privacy: .public)")
                if !searchedLngrs.isEmpty {
                    lngrs.lingeries = searchedLngrs
                    searchedFailed = false
                } else {
                    logger.log("Didn't find anything")
                    lngrs.lingeries = []
                    searchedFailed = true
                    lngrs.LoadLngrs(url: "https://nkd_worker.wttp.workers.dev/?url=https://www.na-kd.com/nl/search-page?q=\(search)".url, lngrsName: lngrs.lngrsName)
                    
                    //                    lngrs.getExtraLngr(url: "https://nkd_worker.wttp.workers.dev/?url=https://www.na-kd.com/nl/search-page?q=\(search)".url)
                    searchedFailed = false
                }
            }
            .onChange(of: isSearching) { newValue in
                if !newValue {
                    print("Searching cancelled")
                }
            }
        }
        .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
            if let id = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                print("info: \(String(describing: userActivity.userInfo))")
                logger.log("Received a payload via spotlight with id: \(id, privacy: .public)")
                DispatchQueue.main.async {
                    if let lngrf = lngrs.lingeries.first(where: {$0.id == id}) {
                        PresentedLngrs = []
                        PresentedLngrs.insert(lngrf, at: 0)
                        selection = lngrs.lngrsName.replacingOccurrences(of: "lngr", with: "")
                    } else {
                        // item could not be found
                        // omdat hij niet gevonden is, is het waarschijnlijk een bh of body
                        lngrs.lingeries = []
                        let ids = "\(id.split(separator: "-")[1])-\(id.split(separator: "-")[2])-\(id.split(separator: "-")[3])"
                        //                        "https://nkd_worker.wttp.workers.dev/getLngr?url=https://www.na-kd.com/nl/search-page?q=\(ids)".url
                        let searchUrl = "https://www.na-kd.com/nl/search-page?q=\(ids)"
                        lngrs.getExtraLngr(url: ("https://nkd_worker.wttp.workers.dev/getMatchingSet/"+searchUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!).url, $PresentedLngrs)
                        selection = lngrs.lngrsName.replacingOccurrences(of: "lngr", with: "")
                    }
                    // 1-1100-008449-0212-004 -> 1100-008449-0212
                }
            } else {
                logger.critical("No CSSearchableItemActivityIdentifier found in spotlight")
            }
        }
    }
}

struct LingeriesView_Previews: PreviewProvider {
    static var previews: some View {
        LingeriesView("https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json", "Slips", "onderbroek",.constant("Slips"))
            .previewInterfaceOrientation(.portrait)
            .previewDevice("iPhone 12")
    }
}

