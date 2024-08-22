//
//  SearchView.swift
//  lngr (iOS)
//
//  Created by Olivier Wittop Koning on 23/06/2024.
//

import os
import SwiftUI
import CoreSpotlight

struct SearchView: View {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "SearchView"
    )
    
    var body: some View {
        var ddata = Data()
        var text = "hi"
        Image(uiImage: (UIImage(data: ddata) ?? UIImage(systemName: "scribble"))!).padding(5)
        Text(text).padding(5)
        Button("GO GO GO") {
            // Fetch the items with a title that starts with the
            // specified string. Perform a case-insensitive comparison.
            let idFromL = "1013-001074-0015"
            let titler = "V-vormig kanten slipje"
            let queryString = "title == '*\(titler)*'c"
            
            let CScontext = CSSearchQueryContext()
            CScontext.fetchAttributes = ["title", "contentDescription" , "contentURL", "thumbnailURL", "thumbnailData"]

            
            // Create the query and specify a handler for the results.
//                            let query = CSSearchQuery(queryString: queryString, queryContext: context)
//                            query.prepareForInterfaceBuilder()
            
            let contexts = CSUserQueryContext()
            contexts.fetchAttributes = ["title", "contentDescription"]
            let query = CSUserQuery(userQueryString: "String", userQueryContext: contexts)
            
            Task {
                do {
                    // Start the query and get the results.
                    for try await element in query.responses {
                        switch(element) {
                            case .item(let item):
                            let attributeSet = item.item.attributeSet
                            let foundTitle = attributeSet.title
                            print("title found: \(String(describing: foundTitle))")
                            let foundDisplayName = attributeSet.contentDescription
                            text = foundDisplayName ?? "found nothing"
                            logger.log("attributeSet: \(attributeSet)")
                            // Use the results here.
                                break
                            case .suggestion(let suggestion):
                            logger.log("suggestion: \(suggestion)")
                            // Use the results here.
                                // Pass suggestions back to the search interface to display.
                                break
                            @unknown default:
                                break
                        }
                    }
                } catch {
                    // Handle any errors.
                }
            }

            
            // Process the results asynchronously.
           /* Task {
                do {
                    // Start the query and iterate over the results.
                    for try await result in query.results {
                        let attributeSet = result.item.attributeSet
                        let foundTitle = attributeSet.title
                        print("title found: \(String(describing: foundTitle))")
                        let foundDisplayName = attributeSet.contentDescription
                        text = foundDisplayName ?? "found nothing"
                        ddata = attributeSet.thumbnailData ?? Data()
                        logger.log("attributeSet: \(attributeSet)")
                        // Use the results here.
                    }
                } catch {
                    logger.log("An error: \(String(describing: error))")
                    // Handle any errors.
                }
            }*/
        }    }
}

#Preview {
    SearchView()
}
