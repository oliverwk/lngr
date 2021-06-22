//
//  DataView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 10/06/2021.
//

import SwiftUI
import CoreData

struct DataView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lngr.objectID, ascending: true)],
        animation: .default)
    private var lngrs: FetchedResults<Lngr>
    
    init() {
        @ObservedObject var theLngrFetcher = LngrFetcher(viewContext: viewContext)
    }
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(lngrs) { lngr in
                    HStack {
                        Text("De \(lngr.naam ?? "Geen naam")")
                        Spacer()
                        Text(lngr.id!)
                    }
                }
            }
            .navigationTitle("lngrs")
        }
    }
    
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
