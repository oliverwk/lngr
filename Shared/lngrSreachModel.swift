//
//  lngrSreachModel.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 10/06/2021.
//

import Foundation
import os

class lngrSreachModel: ObservableObject {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "lngrSreachModel"
    )
    @Published var lingerie: Lingerie?
    @Published var IsSpotlightLink = false
    
    func FoundSpotlightlink(lngr: Lingerie) -> Void {
        self.logger.log("[SPOTLIGHT] Found spotlight item so showing \(lngr.naam, privacy: .public)")
        self.IsSpotlightLink = true
        self.lingerie = lngr
    }
}
