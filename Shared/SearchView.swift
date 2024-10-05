//
//  SearchView.swift
//  lngr (iOS)
//
//  Created by Olivier Wittop Koning on 23/06/2024.
//

import os
import SwiftUI
import CoreData
import CoreSpotlight

struct SearchView: View {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "SearchView"
    )
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: [SortDescriptor(\LNGR.prijs)])
    var lingeris: FetchedResults<LNGR>
    
    @State var ddata = Data()
    @State var text = "hi"
    @State private var searchText: String = "String"
    
    
    
    func runSearch(_ text: String) {
        var allItems = [CSSearchableItem]()
        let queryString = "title == \"*\(text)*\"c"
        
        let context = CSSearchQueryContext()
        context.fetchAttributes = ["title", "contentDescription" , "contentURL", "thumbnailURL", "thumbnailData"]
        
        let searchQuery = CSSearchQuery(queryString: queryString, queryContext: context)
        
        searchQuery.foundItemsHandler = { items in
            allItems.append(contentsOf: items)
        }
        
        searchQuery.completionHandler = { error in
            DispatchQueue.main.async {
                if allItems.count >= 1{
                    self.text = allItems[0].attributeSet.contentDescription ?? "hi"
                    self.ddata = allItems[0].attributeSet.thumbnailData ?? Data()
                }
            }
        }
        
        searchQuery.start()
    }
    
    func handleUser() async {
        // Fetch the items with a title that starts with the
        // specified string. Perform a case-insensitive comparison.
        //        let idFromL = "1013-001074-0015"
        let titler = "kanten"
        //        let titler = "String"
        
        let contexts = CSUserQueryContext()
        contexts.fetchAttributes = ["title", "contentDescription"]
        contexts.maxResultCount = 15
        let query = CSUserQuery(userQueryString: titler, userQueryContext: contexts)
        
        do {
            // Start the query and get the results.
            for try await element in query.responses {
                switch(element) {
                case .item(let item):
                    let attributeSet = item.item.attributeSet
                    logger.log("title found: \(String(describing: attributeSet.title))")
                    logger.log("contentDescription found: \(String(describing: attributeSet.contentDescription))")
                    logger.log("attributeSet: \(attributeSet)")
                    
                    break
                case .suggestion(let suggestion):
                    logger.log("suggestion: \(String(describing: suggestion.suggestion.localizedAttributedSuggestion.characters))")
                    logger.log("suggestion: \(suggestion.suggestion.debugDescription)")
                    // Use the results here.
                    // Pass suggestions back to the search interface to display.
                    break
                @unknown default:
                    break
                }
            }
        } catch {
            logger.log("An error: \(String(describing: error))")
            // Handle any errors.
        }
    }
    
    func addLngrToData(_ lngr: Lingerie) async {
        let TheLNGR = LNGR(context: moc)
        TheLNGR.naam = lngr.naam
        TheLNGR.prijs = lngr.prijs
        TheLNGR.nkdid = lngr.id
        TheLNGR.imagesUrls = lngr.imageUrls
        let imgData = await fetchImageData(url: lngr.SecondImage)
        TheLNGR.image = imgData
        
        do {
            try moc.save()
        } catch {
            print("[ERROR] Er een error bij het opslaan naar core data met de error: \(String(describing: error)) en de lngr: \(lngr.description)")
        }
    }
    
    func fetchImageData(url: URL) async -> Data? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("[ERROR] Er was geen data met het laden een url: \(url.absoluteString) Met de error: \(String(describing: error))")
            return nil
        }
    }
    
    var body: some View {
        
        VStack {
            List {
                ForEach(lingeris) { lngr in
                    VStack {
                        HStack {
                            VStack {
                                Text("\(lngr.naam ?? "no naam")")
                                Text("\((lngr.nkdid ?? "1-1013-no id").replacingOccurrences(of: "1-1013-", with: ""))")
                            }
                            Spacer()
                            VStack {
                                Text("\(lngr.image?.count ?? 0)")
                                Text("\(lngr.kleur ?? "no kleur")")
                            }
                        }
                        if lngr.image != nil {
                            Image(uiImage: (UIImage(data: lngr.image!))!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
            }
            
            HStack {
                Button("Add to core") {
                    Task {
                        await addLngrToData(Lingerie.TheLingerie)
                    }
                }
               
                Text("the lngr: \(String(describing: UserDefaults(suiteName: "lngrMeIndex")?.object(forKey: "SlipsIndexLngrs") as? String ?? "Nothing").count)").padding(5)
                Button("Search") {
                    // Create a fetch request for the Lngr entity
                    let fetchRequest = NSFetchRequest<LNGR>(entityName: "LNGR")
                    let idToSearch = "1-1013-001074-0015-004"
                    // Set a predicate to fetch only the Lngr with the given id
                    fetchRequest.predicate = NSPredicate(format: "nkdid == %@", idToSearch as String)
                    // Execute the fetch request and return the result
                    let lngrs = try? moc.fetch(fetchRequest)
                    let myLNGR = lngrs?.first
                    print(myLNGR as Any) // Assuming id is unique, so we fetch the first result
                    self.text = myLNGR?.naam ?? "no naam"
                    
                }
            }
            
            TextField("Enter your name", text: $searchText)
                .onSubmit {
                    runSearch(searchText)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            HStack {
                Button("Paul") {
                    Task {
                        runSearch("body")
                    }
                }.padding(5).buttonStyle(.bordered)
                Button("Users") {
                    Task {
                        await handleUser()
                    }
                }.padding(5).buttonStyle(.bordered)
                Button("GO GO GO") {
                    // Fetch the items with a title that starts with the
                    // specified string. Perform a case-insensitive comparison.
                    let idFromL = "1013-001074-0015"
                    let queryString = "containerIdentifier == '*\(idFromL)*'c"
                    
                    let CScontext = CSSearchQueryContext()
                    CScontext.fetchAttributes = ["title", "contentDescription" , "contentURL", "thumbnailURL", "thumbnailData"]
                    
                    
                    // Create the query and specify a handler for the results.
                    let query = CSSearchQuery(queryString: queryString, queryContext: CScontext)
                    query.prepareForInterfaceBuilder()
                    
                    // Process the results asynchronously.
                    Task {
                        do {
                            // Start the query and iterate over the results.
                            for try await result in query.results {
                                let attributeSet = result.item.attributeSet
                                let foundTitle = attributeSet.title
                                logger.log("title found: \(String(describing: foundTitle))")
                                let foundDisplayName = attributeSet.contentDescription
                                text = foundDisplayName ?? "found nothing"
                                self.ddata = attributeSet.thumbnailData ?? Data()
                                logger.log("attributeSet: \(attributeSet)")
                                // Use the results here.
                            }
                        } catch {
                            logger.log("An error: \(String(describing: error))")
                            // Handle any errors.
                        }
                    }
                }
            }.padding(.bottom)
        }
    }
}

#Preview {
    SearchView()
}
