//
//  lngrData.swift
//  lngr
//
//  Created by Olivier Koning on 23/06/2024.
//

import CoreData
import Foundation


class CoreDataStack: ObservableObject {
    let container = NSPersistentContainer(name: "lngr")
    
    init() {
        container.loadPersistentStores { _, error in
             self.container.viewContext.mergePolicy = NSOverwriteMergePolicy
            
            if let error {
                // `fatalError(_:file:line:)` during development.
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        } }
    
    // Add a convenience method to commit changes to the store.
    func save() {
        // Verify that the context has uncommitted changes.
        guard container.viewContext.hasChanges else { return }
        
        do {
            // Attempt to save changes.
            try container.viewContext.save()
            
        } catch {
            // Handle the error appropriately.
            print("Failed to save the context:", error.localizedDescription)
        }
    }
    
    
    
}

extension LNGR {
    static var TheLingerie: LNGR {
       let ln = LNGR()
        ln.naam = Lingerie.TheLingerie.naam
        ln.prijs = Lingerie.TheLingerie.prijs
        ln.nkdid = Lingerie.TheLingerie.id
        ln.url = Lingerie.TheLingerie.url
        ln.kleur = Lingerie.TheLingerie.kleur
        return ln
    }
}
