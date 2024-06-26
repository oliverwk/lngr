//
//  LingerieFetcherSpotlight.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 26/06/2021.
//

import CoreSpotlight
#if os(iOS)
import MobileCoreServices
#endif

extension LingerieFetcher {
    
    /// Adds te specifed Lingerie to spotlight index
    /// - Parameters:
    ///   - lngrName: The type of Lingerie
    ///   - lngrs: The Lingeries to add to spotlight
    /// - Returns: Nothing
    func AddToSpotlightWithId(lngrName: String, lngrs: [Lingerie]) -> Void {
        let testing = false
        var idsToUserDefaults = [String]()
        let idsFromUserDefaults = UserDefaults.standard.object(forKey: "\(lngrName)IdsIndexInSpotlight") as? [String] ?? [String]()
        idsToUserDefaults = idsFromUserDefaults
        self.logger.log("\(lngrName, privacy: .public)IdsFromUserDefaults: \(idsFromUserDefaults, privacy: .public)")
        for lngr in lngrs {
            if !idsFromUserDefaults.contains(lngr.id) || testing {
                self.logger.log("Indexing in spotlight: \(lngr.naam)")
                let item = indexWithId(lngr, lngrName: lngrName)
                CSSearchableIndex.default().indexSearchableItems([item]) { error in
                    if let error = error {
                        self.logger.error("[SPOTLIGHT] [ERROR] Er was indexing error: \(error.localizedDescription, privacy: .public)")
                    } else {
                        self.logger.log("[SPOTLIGHT] Search item successfully indexed! \(lngr.naam, privacy: .public), \(lngr.id, privacy: .public)")
                        idsToUserDefaults.insert(lngr.id, at: idsToUserDefaults.count)
                        UserDefaults.standard.set(idsToUserDefaults, forKey: "\(lngrName)IdsIndexInSpotlight")
                        idsToUserDefaults = UserDefaults.standard.object(forKey: "\(lngrName)IdsIndexInSpotlight") as? [String] ?? [String]()
                    }
                }
            } else {
                self.logger.log("\(lngr.id, privacy: .public) is already indexed, \(lngr.naam, privacy: .public)")
            }
        }
        self.logger.log("idsToUserDefaults \("\(lngrName)IdsIndexInSpotlight", privacy: .public): \(UserDefaults.standard.object(forKey: "\(lngrName)IdsIndexInSpotlight") as? [String] ?? [String](), privacy: .public)")
    }
    
    /// Makes a spotlight item with specifedLingerie
    /// - Parameter lngr: Lingerie to be added to spotlight item
    /// - Returns: Spotlight item
    func indexWithId(_ lngr: Lingerie, lngrName: String) -> CSSearchableItem {
        self.logger.log("[SPOTLIGHT] indexing: \(lngr.description, privacy: .public)")
        let attributeSet = CSSearchableItemAttributeSet(contentType: UTType.jpeg)
        attributeSet.domainIdentifier = "nl.wittopkoning.lngr"
        attributeSet.keywords = [lngr.id, lngr.url, lngr.naam]
        attributeSet.title = lngr.naam
        attributeSet.contentDescription = "De \(lngr.naam) kost €\(lngr.prijs)"
        attributeSet.contentURL = URL(string: lngr.url)!
        attributeSet.thumbnailURL = URL(string: lngr.img_url)!
        attributeSet.containerDisplayName = lngrName
        attributeSet.containerIdentifier = lngrName
        let request = URLRequest(url:  URL(string: lngr.img_url)!)
        if let cachedResponse = URLSession.shared.configuration.urlCache?.cachedResponse(for: request), let _ = cachedResponse.response as? HTTPURLResponse {
            attributeSet.thumbnailData = cachedResponse.data
        }
        
        let item = CSSearchableItem(uniqueIdentifier: lngr.id, domainIdentifier: "nl.wittopkoning.lngr", attributeSet: attributeSet)
        return item
    }
    
    internal func reset() {
        logger.critical("Reseting")
        let defaults = UserDefaults(suiteName: "nl.wittopkoning.lngr.lngrs")!
        for lngrsName in ["lngrSlips", "lngrBodys"] {
            logger.log("Deleting: \(lngrsName, privacy: .public)IdsIndexInSpotlight")
            defaults.removeObject(forKey: "\(lngrsName)IdsIndexInSpotlight")
        }
        deleteSpotlight()
    }
    
    internal func deleteSpotlight() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: ["nl.wittopkoning.lngr"]) { error in
            if let errs = error {
                self.logger.fault("An error happend while reseting the spolight index: \(errs.localizedDescription, privacy: .public)")
            }
        }
    }
    
}
