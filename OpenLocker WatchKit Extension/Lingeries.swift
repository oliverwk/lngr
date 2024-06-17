//
//  Lingeries.swift
//  OpenLocker WatchKit App
//
//  Created by Olivier Wittop Koning on 14/06/2024.
//

import Foundation
import SwiftUI
import os

struct LingeriesView: View {
    @StateObject var lngrs = LingerieFetcher()
    var body: some View {
        NavigationStack {
            List {
                ForEach(lngrs.lingeries) { lngr in
                    lngrRow(lngr: lngr)
                }
            }
            .listStyle(.carousel)
        }
        .navigationTitle("Slips")
        .onAppear {
            Task { await lngrs.load() }
        }
    }
}

struct lngrRow: View {
    let lngr: Lingerie
    var body: some View {
        AsyncImage(url: URL(string: lngr.img_url_sec+"?width=200")!) { img in
            img
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        } placeholder: {
            Image(systemName: "square.and.arrow.down")
                .foregroundStyle(.white)
        }
        .overlay(Text("\(lngr.naam)")
            .padding(.bottom, 25.0)
            .shadow(radius: 11)
            .foregroundColor(.white)
            .font(.body))
    }
}


public class LingerieFetcher: ObservableObject {
    let logger = Logger(
        subsystem: "nl.wittopkoning.openlocker",
        category: "LingerieFetcher"
    )
    @Published var lingeries = [Lingerie]()
    let lngrUrl = URL(string: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")!
    
    func load() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: lngrUrl)
            let fetchedData = try? JSONDecoder().decode([Lingerie].self, from: data)
            DispatchQueue.main.async {
                self.lingeries = fetchedData ?? []
            }
        } catch {
            logger.log("There was an error \(String(describing: error)) in url")
        }
    }
}

#Preview {
    LingeriesView()
}
