//
//  LinkView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 05/03/2021.
//

import SwiftUI
import Combine
import os.log

struct LinkView: View {
    let lingerie: Lingerie
    let locale = Locale.current
    @StateObject private var ImageFetcher: ImageFetchers
    init(lingerie: Lingerie) {
        self.lingerie = lingerie
        _ImageFetcher = StateObject(wrappedValue: ImageFetchers(ImageUrls: lingerie.imageUrls))
    }
    
    var body: some View {
        VStack {
            ImageFetcher.images
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .cornerRadius(5)
                .padding(10)
                .animation(.easeInOut)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onEnded({ value in
                                if value.translation.width < 0 {
                                    // left
                                    ImageFetcher.index -= 1
                                    ImageFetcher.load()
                                } else if value.translation.width > 0 {
                                    // right
                                    ImageFetcher.index += 1
                                    ImageFetcher.load()
                                } else {
                                    ImageFetcher.index += 1
                                    ImageFetcher.load()
                                }
                            }))
            Text("\(locale.currencySymbol ?? "") \(String(lingerie.prijs))")
                .padding(.bottom, 10.0)
                .foregroundColor(.secondary)
        }.navigationBarTitle(Text(lingerie.naam), displayMode: .inline)
    }
    
    public class ImageFetchers: ObservableObject {
        private let logger = Logger(
            subsystem: "nl.wittopkoning.lngr",
            category: "ImageFetchers"
        )
        @Published var index: Int = 1
        @Published var images: Image = Image("04k")
        var TheImageUrls: [String]
        
        public func 🚫() {
            let genarator = UINotificationFeedbackGenerator()
            genarator.notificationOccurred(.error)
        }
        
        init(ImageUrls: [String]) {
            self.TheImageUrls = ImageUrls
            load()
        }
        
        func load() {
            //if self.index >= self.TheImageUrls.count {
            if self.index >= TheImageUrls.count {
                self.index = 0
            } else if self.index <= -1 {
                self.index = TheImageUrls.count - 1
            }
            self.logger.info("\(self.index, privacy: .public) >= \(self.TheImageUrls.count, privacy: .public):\(self.index >= self.TheImageUrls.count, privacy: .public)")
            URLSession.shared.dataTask(with: URL(string: self.TheImageUrls[self.index])! ) {(data, response, error) in
                if let image = UIImage(data: data!) {
                    DispatchQueue.main.async {
                        self.images = Image(uiImage: image)
                    }
                } else {
                    if let response = response as? HTTPURLResponse {
                        self.logger.error("[ERROR] Er was een error met het laden een afbeelding url: \(self.TheImageUrls[self.index], privacy: .public) en met response: \(response) Met de error: \(error?.localizedDescription as! NSObject)")
                        // as! NSObject weg halen
                    } else {
                        self.logger.error("[ERROR] Er was een error met het laden een afbeelding url: \(self.TheImageUrls[self.index], privacy: .public) Met de error: \(error?.localizedDescription as! NSObject)")
                    }
                    DispatchQueue.main.async {
                        self.🚫()
                        self.images = Image(systemName: "multiply.circle")
                    }
                }
            }.resume()
        }
    }
}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(lingerie: Lingerie(id: "01094830958049238", naam: "Klassiek Katoenen String", prijs: 69.95, img_url:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg", img_url_sec:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg",imageUrls: [
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"
        ]))
        .preferredColorScheme(.light)
        .previewDevice("iPhone 7")
    }
}
