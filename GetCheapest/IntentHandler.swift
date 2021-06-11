//
//  IntentHandler.swift
//  GetCheapest
//
//  Created by Olivier Wittop Koning on 16/05/2021.
//


import Intents
import Foundation
import os

let logger = Logger(
    subsystem: "nl.wittopkoning.lngr.GetCheapest",
    category: "LngrIntent"
)

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        logger.log("Beginning to handle GetCheapestIntentHandler")
        //logger.log("Handleing: \((intent as! GetCheapestIntent).value(forKey: "sort") ?? "theSort")")
        
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is GetCheapestIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return GetCheapestIntentHandler()
    }
}




public class GetCheapestIntentHandler: NSObject, GetCheapestIntentHandling {
    
    public func handle(intent: GetCheapestIntent, completion: @escaping (GetCheapestIntentResponse) -> Void) {
        logger.log("CheapestIntentHandler: \(intent, privacy: .public)")
        let lngr = Lingerie(id: "1013-000283-0002", naam: "Cheeky Lace Panty", prijs: 8.47, img_url: "https://www.na-kd.com/resize/globalassets/nakd_cheeky_lace_panty_1013-000283-0002_01j.jpg", img_url_sec: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg", imageUrls: ["https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg", "https://www.na-kd.com/resize/globalassets/nakd_cheeky_lace_panty_1013-000283-0002_02h.jpg"], url: "https://www.na-kd.com/en/products/cheeky-lace-panty-black")
        var TheLngr: TheLingerie
        
        let sort = intent.sort
        switch sort {
        case Lingeries.slip:
            TheLngr = TheLingerie(identifier: intent.identifier, display: "De \(lngr.naam) voor \(lngr.prijs)", pronunciationHint: "Get the cheapest", subtitle: "De \(lngr.naam) voor \(lngr.prijs) in de kleuren \(lngr.imageUrls) te vinden op \(lngr.url)", image: INImage(url: URL(string: lngr.img_url)!))
            
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            // Hier userdefault of network request
            TheLngr.prijs = 10.2
            TheLngr.kleur = ["wit", "zwart"]
            
            completion(.success(sort: sort, lngr: TheLngr))
        case Lingeries.bra:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            TheLngr = TheLingerie(identifier: intent.identifier, display: "De \(lngr.naam) voor \(lngr.prijs)", pronunciationHint: "Get the cheapest", subtitle: "De \(lngr.naam) voor \(lngr.prijs) in de kleuren \(lngr.imageUrls) te vinden op \(lngr.url)", image: INImage(url: URL(string: lngr.img_url)!))
            completion(.success(sort: sort, lngr: TheLngr))
        case Lingeries.body:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            //Getlngr func
            
            TheLngr = TheLingerie(identifier: intent.identifier, display: "De \(lngr.naam) voor \(lngr.prijs)", pronunciationHint: "Get the cheapest", subtitle: "De \(lngr.naam) voor \(lngr.prijs) in de kleuren \(lngr.imageUrls) te vinden op \(lngr.url)", image: INImage(url: URL(string: lngr.img_url)!))
            completion(.success(sort: sort, lngr: TheLngr))
        default:
            logger.log("Setting sort: .notFound, bacause intent sort was empty")
            
            completion(.notFound(sort: sort))
        }
        
    }
    
    public func resolveSort(for intent: GetCheapestIntent, with completion: @escaping (GetCheapestSortResolutionResult) -> Void) {
        logger.log("CheapestIntentHandler Resolving sort: \(intent, privacy: .public)")
        
        let sort = intent.sort
        switch intent.sort {
        case Lingeries.slip:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            completion(.success(with: sort))
        case Lingeries.bra:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            completion(.success(with: sort))
        case Lingeries.body:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            completion(.success(with: sort))
        default:
            logger.log("Setting sort: .notfound, bacause intent sort was empty")
            completion(.unsupported(forReason: .notFound))
        }
    }

    /*public func confirm(intent: GetCheapestIntent, completion: @escaping (GetCheapestIntentResponse) -> Void) {
         let sort: Lingeries = .slip
         completion(GetCheapestIntentResponse.success(sort: sort))
     }*/
}

