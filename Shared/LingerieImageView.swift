//
//  LingerieImageView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import SwiftUI
import os

struct LingerieImageView: View {
    private enum LoadState {
        case loading, success, failure
    }
    
    private class Loader: ObservableObject {
        private let logger = Logger(
            subsystem: "nl.wittopkoning.lngr",
            category: "LingerieImageView"
        )
        var data = Data()
        var state = LoadState.loading
        
        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                logger.fault("[Fatal] Invalid URL: \(url, privacy: .public)")
                return
            }
            
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = false
            config.allowsConstrainedNetworkAccess = false
            config.allowsExpensiveNetworkAccess = false
            config.multipathServiceType = .none
            
            let session = URLSession(configuration: config)
            
            session.dataTask(with: parsedURL) { data, response, error in
                //            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    if let response = response as? HTTPURLResponse {
                        self.logger.error("[ERROR] Er was geen data bij het laden een afbeelding url: \(url, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.debugDescription, privacy: .public)")
                    } else {
                        self.logger.error("[ERROR] Er was geen data bij het laden een afbeelding url: \(url, privacy: .public) Met de error: \(error.debugDescription, privacy: .public)")
                    }
                    self.state = .failure
                }
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }
    
    @StateObject private var loader: Loader
    var loading: Image
    var failure: Image
    
    var body: some View {
        selectImage()
            .resizable()
    }
    
    init(url: String, loading: Image = Image("01j"), failure: Image = Image(systemName: "multiply.circle")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }
    
    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
}
