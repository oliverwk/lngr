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
        print("Handleing: \((intent as! GetCheapestIntent).value(forKey: "sort") ?? "theSort")")
       
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        // let intent = IntentHelper.getCheapestIntent(for: sort)
        guard intent is GetCheapestIntent else {
                  fatalError("Unhandled intent type: \(intent)")
        }
        return GetCheapestIntentHandler()
    }
}

public class GetCheapestIntentHandler: NSObject, GetCheapestIntentHandling {
//    logger.log("Beginning to handle GetCheapestIntentHandler")
//    Dit nog in init doen

    public func handle(intent: GetCheapestIntent, completion: @escaping (GetCheapestIntentResponse) -> Void) {
        logger.log("CheapestIntentHandler: \(intent, privacy: .public)")
        let sort = intent.sort
        switch sort {
            case Lingeries.slip:
                logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestIntentResponse.success(sort: sort))
            case Lingeries.bra:
                logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestIntentResponse.success(sort: sort))
            case Lingeries.body:
                logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestIntentResponse.success(sort: sort))
            default:
                logger.log("Setting sort: .notFound, bacause intent sort was empty")
                //completion(GetCheapestIntentResponse.success(with: sort))
                completion(GetCheapestIntentResponse.notFound(sort: sort))
        }
        
        //let sort: Lingeries = .slip
        //completion(GetCheapestIntentResponse.success(sort: sort))
    }
    
    public func resolveSort(for intent: GetCheapestIntent, with completion: @escaping (GetCheapestSortResolutionResult) -> Void) {
        logger.log("CheapestIntentHandler: \(intent, privacy: .public)")
        
        let sort = intent.sort
        switch intent.sort {
            case Lingeries.slip:
                logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestSortResolutionResult.success(with: sort))
            case Lingeries.bra:
                logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestSortResolutionResult.success(with: sort))
            case Lingeries.body:
                logger.log("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestSortResolutionResult.success(with: sort))
            default:
                let sort: Lingeries = .slip
                logger.log("Setting sort: .slip, bacause intent sort was empty")
                completion(GetCheapestSortResolutionResult.success(with: sort))
                //completion(GetCheapestSortResolutionResult.unsupported(reason: .notFound))
        }
        
        /*if let sort = intent.sort {
            logger.notice("Setting sort: \(sort.rawValue, privacy: .public)")
            completion(GetCheapestSortResolutionResult.success(with: sort))
        } else {
            let sort: Lingeries = .slip
            logger.notice("Setting sort: .slip, bacause intent sort was empty")
            completion(GetCheapestSortResolutionResult.unsupported(reason: .notFound))
        }*/
    }
    public func confirm(intent: GetCheapestIntent, completion: @escaping (GetCheapestIntentResponse) -> Void) {
        let sort: Lingeries = .slip
        completion(GetCheapestIntentResponse.success(sort: sort))
    }
}
        
