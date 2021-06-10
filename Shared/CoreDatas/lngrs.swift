//
//  lngrs.swift
//  lngr
//
//  Created by Maarten Wittop Koning on 10/06/2021.
//

import Combine
import SwiftUI
import CoreData
import CoreSpotlight
import MobileCoreServices
import os


class LngrFetcher: ObservableObject {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LngrFetcher"
    )
    @Published var lngrs = [Lingerie]()
    private var viewContexter: NSManagedObjectContext
    
    func index(_ lngr: Lingerie) {
        self.logger.log("[SPOTLIGHT] indexing: \(lngr.description, privacy: .public)")
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = lngr.naam
        attributeSet.contentDescription = "De \(lngr.naam) kost \(lngr.prijs)"
        attributeSet.thumbnailURL = URL(string: lngr.img_url)!
        
        let item = CSSearchableItem(uniqueIdentifier: lngr.id, domainIdentifier: "nl.wittopkoning.lngr", attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                self.logger.error("[SPOTLIGHT] [ERROR] Er was indexing error: \(error.localizedDescription, privacy: .public)")
            } else {
                self.logger.log("[SPOTLIGHT] Search item successfully indexed! \(lngr.description, privacy: .public)")
            }
        }
    }
    
    /*private func deleteItems(index: Int) {
     do {
     let lngr = lngrs[index]
     self.viewContexter.delete(lngr)
     try  self.viewContexter.save()
     } catch {
     // Replace this implementation with code to handle the error appropriately.
     // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     let nsError = error as NSError
     fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
     }
     }*/
    
    private func addItem(lnger: Lingerie) {
        let newLngr = Lngr(context: self.viewContexter)
        newLngr.naam = lnger.naam
        newLngr.prijs = lnger.prijs
        newLngr.id = lnger.id
        newLngr.url = URL(string: lnger.url)!
        
        do {
            try self.viewContexter.save()
            print("Saved succefully")
           
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            if nsError.code == 133021 {
                print("Er is al een item met het zelfde id")
            } else {
                print("Got an error at addItem: \(nsError.debugDescription)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContexter = PersistenceController.shared.container.viewContext
        //viewContexter.reset()
        let Url = URL(string: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")!
        self.logger.log("Making request with: \(Url.absoluteString, privacy: .public)")
        URLSession.shared.dataTask(with: Url) { [self](data, response, error) in
            self.logger.log("Got back an response")
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    self.logger.log("Parsed json \(decodedLists[0], privacy: .public)")
                    DispatchQueue.main.async {
                        self.lngrs = decodedLists
                    }
                    for talngr in decodedLists {
                        self.logger.log("talngr: \(talngr.id, privacy: .public) \(talngr.naam, privacy: .public)")
                        // self.logger.log("HasID:", (decodedLists.filter { $0.id == talngr.id }).count, privacy: .public)
                        addItem(lnger: talngr)
                    }
                } else if let error = error {
                    if let response = response as? HTTPURLResponse {
                        self.logger.fault("[ERROR] Er was geen data met het laden een url: \(Url, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    } else {
                        self.logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(Url, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                    }
                }
            } catch {
                if let response = response as? HTTPURLResponse {
                    self.logger.fault("[ERROR] Er was geen data met het laden een url: \(Url, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                } else {
                    self.logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(Url, privacy: .public) met data \(String(decoding: data!, as: UTF8.self), privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                }
            }
        }.resume()
    }
}
