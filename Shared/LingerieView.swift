//
//  LingerieView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 05/03/2021.
//

import SwiftUI
import Combine
import os

struct LingerieView: View {
    let lingerie: Lingerie
    let locale = Locale.current
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingerieView"
    )
    
    @StateObject private var ImageFetcher: ImageFetchers
    @State var favoriteColor = KleurFamilie(id: "01094830958049238", naam: "zwart", hex: "#000000", imgUrl: "about:blank", URLS: "about:blank")

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
                    .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.width < 0 {
                                // left
                                ImageFetcher.index -= 1
                                ImageFetcher.load()
                            } else if value.translation.width > 0 {
                                ImageFetcher.index += 1
                                ImageFetcher.load()
                            } else {
                                ImageFetcher.index += 1
                                ImageFetcher.load()
                            }
                        }))
                Text("\(locale.currencySymbol ?? "") \(String(lingerie.prijs))")
                    .padding(.bottom, 10.0)
                //.foregroundColor(.secondary)
                    .foregroundColor(favoriteColor.colour)
                Picker("What is your favorite color?", selection: $favoriteColor) {
                    ForEach(lingerie.kleurFam, id: \.self) {
                        Text($0.naam)
                            .foregroundColor($0.colour)
                    }
                }
                .onChange(of: favoriteColor) { newFavoriteColor in
                    print("favoriteColor \(favoriteColor)")
                    print("\(favoriteColor.id) == \(lingerie.id.split(separator: "-")[...3].joined(separator: "-"))")
                    // Check if they have the same id, so they have the same colour, but reomve the last three characters, because that is the size
                    if (favoriteColor.id == lingerie.id.split(separator: "-")[...3].joined(separator: "-")) {
                        ImageFetcher.TheImageUrls = lingerie.imageUrls
                        print(lingerie.imageUrls)
                        ImageFetcher.index = 0
                        print("Dit is de orginele lngr")
                    } else if (false) {
                        // TODO: Hier de huigde database zoek of de zelfde kleur er in zit
//                  } else if (lingeries.contains { $0.id == favoriteColor.id }) {
//                      let llngr = lingeries.filter { $0.id == favoriteColor.id }
//                      ImageFetcher.TheImageUrls = llngr[0].imageUrls
//                      ImageFetcher.index = 0
//                      print("Dit een andere lngr, maar hij zit wel in de huidige database")
                    } else {
                        ImageFetcher.TheImageUrls = [newFavoriteColor.imgUrl]
                        ImageFetcher.index = 0
                        getExtraImages(searchUrl: newFavoriteColor.url, imageFetcher: ImageFetcher)
                        print("Dit een andere lngr, waar wij geen info over hebben, dus nieuwe aan het halen zijn")
                    }
                    ImageFetcher.load()
                }
                .onAppear {
                    favoriteColor = self.lingerie.kleurFam[0]
                }
                .pickerStyle(.segmented)
                
            }.navigationBarTitle(lingerie.naam, displayMode: .inline)
        
    }
    
    func getExtraImages(searchUrl: URL, imageFetcher: ImageFetchers)  {
        let url = URL(string: "https://nkd_worker.wttp.workers.dev/getImagesColour/"+searchUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let d = data {
                    let decodeImageUrls = try JSONDecoder().decode([String].self, from: d)
                    DispatchQueue.main.async {
                        imageFetcher.TheImageUrls = decodeImageUrls
                        ImageFetcher.index = 0
                    }
                } else if let error = error {
                    if let response = response as? HTTPURLResponse {
                        self.logger.fault("[ERROR] Er was geen data met het laden een url: \(searchUrl.absoluteString, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    }
                }
            } catch {
                if let response = response as? HTTPURLResponse {
                    self.logger.fault("[ERROR] Er was geen data met het laden een url: \(searchUrl.absoluteString, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                }
            }
        }.resume()
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
            self.logger.info("\(self.index, privacy: .public) >= \(self.TheImageUrls.count, privacy: .public):\(self.index >= self.TheImageUrls.count, privacy: .public) met url: \(self.TheImageUrls[self.index])!)")
            URLSession.shared.dataTask(with: URL(string: self.TheImageUrls[self.index])! ) {(d, response, error) in
                if let data = d {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            withAnimation {
                                self.images = Image(uiImage: image)
                            }
                        }
                    } else {
                        self.logger.error("[ERROR] Er was een error met het laden een afbeelding url nar UIImage: \(self.TheImageUrls[self.index], privacy: .public) Met de error: \(error.debugDescription, privacy: .public)")
                    }
                } else {
                    if let response = response as? HTTPURLResponse {
                        self.logger.error("[ERROR] Er was een error met het laden een afbeelding url: \(self.TheImageUrls[self.index], privacy: .public) en met response: \(response) Met de error: \(error.debugDescription, privacy: .public)")
                    } else {
                        self.logger.error("[ERROR] Er was een error met het laden een afbeelding url: \(self.TheImageUrls[self.index], privacy: .public) Met de error: \(error.debugDescription, privacy: .public)")
                    }
                    DispatchQueue.main.async {
                        self.🚫()
                        withAnimation {
                            self.images = Image(systemName: "multiply.circle")
                        }
                    }
                }
            }.resume()
        }
    }
}

struct LingerieView_Previews: PreviewProvider {
    static var previews: some View {
        LingerieView(lingerie: Lingerie(id: "1-1013-000820-0138", naam: "Klassiek Katoenen String", prijs: 69.95, img_url:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg", img_url_sec:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg",imageUrls: [
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"
        ], url: "https://www.na-kd.com/nakd_classic_cotton_thong", kleur: "Grijs", kleurFam: [
            KleurFamilie(id: "1-1013-000820-0138", naam: "Grijs", hex: "#bfbcb4", imgUrl: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640", URLS: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"),
            KleurFamilie(id: "1-1013-000820-0138", naam: "Zwart", hex: "#000000", imgUrl: "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_01j.jpg?width=640", URLS: "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_01j.jpg?width=640")]))
        .preferredColorScheme(.light)
    }
}


// MARK: - GetImagesColour
struct GetImagesColour: Codable, CustomStringConvertible {
    var description: String {
        return "{imageUrls: \(imageUrls), naam: \(naam) prijs: \(prijs), kleur: \(kleur), img_url: \(imgURL), url: \(url)}"
    }
    
    let imageUrls: [String]
    let naam, prijs, kleur: String
    let imgURL: String
    let url: String
    let id: String

    enum CodingKeys: String, CodingKey {
        case imageUrls, naam, prijs, kleur
        case imgURL = "img_url"
        case url, id
    }
}
