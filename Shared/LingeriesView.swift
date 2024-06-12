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
    @Binding var selection: String
    @State private var StopIndex = 34
    @StateObject private var lngrs: LingerieFetcher
    @State var search = ""
    @State var searchedFailed = false
    
    init(_ Url: String, _ title: String, _ sel: Binding<String>) {
        self.Url = Url
        self.title = title
        self._selection = sel
        _lngrs = StateObject(wrappedValue: LingerieFetcher(URL(string: Url)!, "lngr\(title)"))
    }
    
    /// Check at the end of the list if extra lingerie should be loded
    func checkIfExtraLngr(TheLingerie: Lingerie) {
        self.StopIndex = lngrs.lingeries.count - 1
        if lngrs.lingeries.count > 0 {
            let currentLngr = lngrs.lingeries.firstIndex(where: { $0.id == TheLingerie.id })
            logger.log("Getting lngr: \(currentLngr == StopIndex, privacy: .public) index: \(currentLngr.debugDescription, privacy: .public) op \(lngrs.lingeries.count, privacy: .public), naam: \(TheLingerie.naam, privacy: .public)")
            if currentLngr == StopIndex {
                logger.log("Getting extra lngr \(StopIndex + 20)")
                let LNurl: String
                if (lngrs.lngrsName == "lngrSlips") {
                    LNurl = "https://nkd_worker.wttp.workers.dev/?count=\(StopIndex + 20)&url=https://www.na-kd.com/nl/category/lingerie--nachtkleding/onderbroeken?sortBy=price"
                } else if (lngrs.lngrsName == "lngrBodys") {
                    LNurl = "https://nkd_worker.wttp.workers.dev/?count=\(StopIndex + 20)&url=https://www.na-kd.com/nl/category/lingerie--nachtkleding/bodys?sortBy=price"
                } else if (lngrs.lngrsName == "lngrBras") {
                    LNurl = "https://nkd_worker.wttp.workers.dev/?count=\(StopIndex + 20)&url=https://www.na-kd.com/nl/category/lingerie--nachtkleding/bhs?sortBy=price"
                } else {
                    LNurl = "https://nkd_worker.wttp.workers.dev/?count=\(StopIndex + 20)&url=https://www.na-kd.com/nl/category/lingerie--nachtkleding/onderbroeken?sortBy=price"
                }
                lngrs.getExtraLngr(url: URL(string: LNurl)!)
            }
        }
    }
    
    public func simpleSuccess() {
#if os(iOS)
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.success)
#endif
    }
    
    @State private var PresentedLngrs: [Lingerie] = []

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
                    HStack {
                        Spacer()
                        Button("Show") {
                            simpleSuccess()
                            lngrs.ShowNotification(true)
                            print("Showing notifaction")
                        }.buttonStyle(.bordered)
                        Spacer()
                    }
                    // TODO: Dit hier onder is voor macos
//                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 20) {
                        ForEach(lngrs.lingeries) { TheLingerie in
                            NavigationLink(value: TheLingerie) {
                                lngrRow(TheLingerie: TheLingerie).onAppear {
                                    checkIfExtraLngr(TheLingerie: TheLingerie)
                                }
                            }
                        }
                    //}
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
                lngrs.LoadLngrs(Url: lngrs.url, lngrsName: lngrs.lngrsName)
            }
            .navigationTitle(title)
            .searchable(text: $search)
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
                    }
                }
            } else {
                logger.critical("No CSSearchableItemActivityIdentifier found in spotlight")
            }
        }
    }
}

struct LingeriesView_Previews: PreviewProvider {
    static var previews: some View {
        LingeriesView("https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json", "Slips", .constant("Slips"))
            .previewInterfaceOrientation(.portrait)
            .previewDevice("iPhone 12")
    }
}

