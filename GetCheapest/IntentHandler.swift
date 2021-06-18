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
        //                let MyLngr = Lingerie(id: "1013-000283-0002", naam: "Cheeky Lace Panty", prijs: 8.47, img_url: "https://www.na-kd.com/resize/globalassets/nakd_cheeky_lace_panty_1013-000283-0002_01j.jpg", img_url_sec: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg", imageUrls: ["https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg", "https://www.na-kd.com/resize/globalassets/nakd_cheeky_lace_panty_1013-000283-0002_02h.jpg"], url: "https://www.na-kd.com/en/products/cheeky-lace-panty-black", kleur: "Black")
        var TheLngr = TheLingerie(identifier: "", display: "")
        
        
        let sort = intent.sort
        switch sort {
        case Lingeries.slip:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            Getlngr(type: sort) { (reLngr: Lingerie?) in
                if let MyLngr = reLngr  {
                    TheLngr = TheLingerie(identifier: intent.identifier, display: "De \(MyLngr.naam) voor €\(MyLngr.prijs)", pronunciationHint: "Get the cheapest", subtitle: "De \(MyLngr.naam) voor \(MyLngr.prijs) in de kleuren \(MyLngr.imageUrls) te vinden op \(MyLngr.url)", image: INImage(url: URL(string: MyLngr.img_url)!))
                    
                    TheLngr.prijs = NSNumber(value: MyLngr.prijs)
                    TheLngr.kleur = [MyLngr.kleur]
                    completion(.success(sort: sort, lngr: TheLngr))
                } else {
                    completion(.notFound(sort: sort))
                    logger.fault("Failed to get the lngr from Getlngr(.slip)")
                }
            }
        case Lingeries.bra:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            Getlngr(type: sort) { (reLngr: Lingerie?) in
                if let MyLngr = reLngr  {
                    TheLngr = TheLingerie(identifier: intent.identifier, display: "De \(MyLngr.naam) voor €\(MyLngr.prijs)", pronunciationHint: "Get the cheapest", subtitle: "De \(MyLngr.naam) voor \(MyLngr.prijs) in de kleuren \(MyLngr.imageUrls) te vinden op \(MyLngr.url)", image: INImage(url: URL(string: MyLngr.img_url)!))
                    TheLngr.prijs = NSNumber(value: MyLngr.prijs)
                    TheLngr.kleur = [MyLngr.kleur]
                    completion(.success(sort: sort, lngr: TheLngr))
                } else {
                    completion(.notFound(sort: sort))
                    logger.fault("Failed to get the lngr from Getlngr(.bra)")
                }
            }
        case Lingeries.body:
            logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
            Getlngr(type: sort) { (reLngr: Lingerie?) in
                if let MyLngr = reLngr  {
                    TheLngr = TheLingerie(identifier: intent.identifier, display: "De \(MyLngr.naam) voor €\(MyLngr.prijs)", pronunciationHint: "Get the cheapest", subtitle: "De \(MyLngr.naam) voor \(MyLngr.prijs) in de kleuren \(MyLngr.imageUrls) te vinden op \(MyLngr.url)", image: INImage(url: URL(string: MyLngr.img_url)!))
                    TheLngr.prijs = NSNumber(value: MyLngr.prijs)
                    TheLngr.kleur = [MyLngr.kleur]
                    completion(.success(sort: sort, lngr: TheLngr))
                } else {
                    completion(.notFound(sort: sort))
                    logger.fault("Failed to get the lngr from Getlngr(.body)")
                }
            }
            completion(.success(sort: sort, lngr: TheLngr))
        default:
            logger.log("Setting sort: .notFound, bacause intent sort was empty")
            
            completion(.notFound(sort: sort))
        }
        
    }
    
    enum LngrErrors: Error {
        case FailedToParse
        case FailedToGet
    }
    
    public func resolveSort(for intent: GetCheapestIntent, with completion: @escaping (GetCheapestSortResolutionResult) -> Void) {
        logger.log("CheapestIntentHandler Resolving sort: \(intent.debugDescription, privacy: .public)")
        
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
}

