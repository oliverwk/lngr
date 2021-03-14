//
//  LinkView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 05/03/2021.
//

import SwiftUI
import Combine



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
                .onTapGesture {
                    ImageFetcher.index += 1
                    ImageFetcher.load()
                }
            Text("\(locale.currencySymbol ?? "") \(String(lingerie.prijs))")
                .padding(.bottom, 10.0)
                .foregroundColor(.secondary)
        }.navigationBarTitle(Text(lingerie.naam), displayMode: .inline)
    }
}

public class ImageFetchers: ObservableObject {
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
        if self.index >= TheImageUrls.count {
                self.index = 0
        }
        //print("\(self.index) >= \(TheImageUrls.count):", self.index >= TheImageUrls.count)
        URLSession.shared.dataTask(with: URL(string: self.TheImageUrls[index])! ) {(data, response, error) in
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    self.images = Image(uiImage: image)
                }
            } else {
                DispatchQueue.main.async {
                    self.🚫()
                    self.images = Image(systemName: "multiply.circle")
                }
            }
        }.resume()
    }
}

struct LinkView_Previews: PreviewProvider {
    static var previews: some View {
        LinkView(lingerie: Lingerie(naam: "Klassiek Katoenen String", prijs: 69.95, img_url:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg", img_url_sec:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg",imageUrls: [
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"
        ]))
        .preferredColorScheme(.light)
        .previewDevice("iPhone 8")
    }
}
