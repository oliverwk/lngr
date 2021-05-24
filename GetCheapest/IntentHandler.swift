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
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        // let intent = IntentHelper.getCheapestIntent(for: sort)
        return self
    }
}

public class GetCheapestIntentHandler: NSObject, GetCheapestIntentHandling {
    public func handle(intent: GetCheapestIntent, completion: @escaping (GetCheapestIntentResponse) -> Void) {
        logger.debug("CheapestIntentHandler: \(intent, privacy: .public)")
        //TODO: hier een switch case ding doen
        let sort: Lingeries = .slip
        completion(GetCheapestIntentResponse.success(sort: sort))
    }
    
    public func resolveSort(for intent: GetCheapestIntent, with completion: @escaping (GetCheapestSortResolutionResult) -> Void) {

        let sort = intent.sort
        switch intent.sort {
            case Lingeries.slip:
                logger.notice("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestSortResolutionResult.success(with: sort))
            case Lingeries.bra:
                logger.notice("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestSortResolutionResult.success(with: sort))
            case Lingeries.body:
                logger.notice("Setting sort: \(sort.rawValue, privacy: .public)")
                completion(GetCheapestSortResolutionResult.success(with: sort))
            default:
                let sort: Lingeries = .slip
                logger.notice("Setting sort: .slip, bacause intent sort was empty")
                completion(GetCheapestSortResolutionResult.success(with: sort))
                //completion(GetCheapestSortResolutionResult.unsupported(reason: .notFound))
        }
        
        /*if let sort = intent.sort {
            var theSort: String {
                     switch sort {
                      case Lingeries.slip:
                          return "slip"
                     case Lingeries.bra:
                          return "bra"
                      case Lingeries.body:
                          return "body"
                      default:
                          return "unknown"
                 }
            }
            // theSort
            logger.notice("Setting sort: \(sort.rawValue, privacy: .public)")
            completion(LingeriesResolutionResult.success(with: sort))
        } else {
            let sort: Lingeries = .slip
            logger.notice("Setting sort: .slip, bacause intent sort was empty")
            completion(LingeriesResolutionResult.success(with: sort))
        }*/
    }
    public func confirm(intent: GetCheapestIntent, completion: @escaping (GetCheapestIntentResponse) -> Void) {
        let sort: Lingeries = .slip
        completion(GetCheapestIntentResponse.success(sort: sort))
    }
}
        
