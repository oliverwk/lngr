//
//  RemoteImage.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import SwiftUI
import os.log

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }
    
    private class Loader: ObservableObject {
        private let logger = Logger(
            subsystem: "nl.wittopkoning.lngr",
            category: "Loader"
        )
        var data = Data()
        var state = LoadState.loading
        
        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                logger.fault("[Fatal] Invalid URL: \(url, privacy: .public)")
                fatalError("Invalid URL: \(url)")
            }
            
            URLSession.shared.dataTask(with: self.parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.logger.error("[ERROR] Er was geen data bij het laden een afbeelding url: \(url, privacy: .public) en met response: \(response as! NSObject, privacy: .public) Met de error: \(error as! NSObject, privacy: .public)")
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
