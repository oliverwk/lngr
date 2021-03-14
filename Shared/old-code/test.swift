//
//  test.swift
//  lngr (iOS)
//
//  Created by Maarten Wittop Koning on 13/03/2021.
//

import SwiftUI
import Combine
struct test: View {
    @ObservedObject var ImageFetcher = ImageFetchers()
    
    var body: some View {
        VStack {
            ImageFetcher.images
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .cornerRadius(5)
                .padding(10)
                .onTapGesture {
                    ImageFetcher.index += 1
                    ImageFetcher.load()
                }
            Text("\(ImageFetcher.index)")
                .padding(.bottom, 10.0)
                .foregroundColor(.secondary)
        }
    }
}

public class ImageFetchers: ObservableObject {
    @Published var index: Int = 1
    @Published var images: Image = Image("04k")
    init() {
        load()
    }
    func load() {
        if self.index > 3 {
                self.index = 0
        }
        print("Index:", index)
        let TheUrls: [URL] = [
            URL(string:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640")!,
            URL(string:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640")!,
            URL(string:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640")!,
            URL(string:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640")!
        ]
        URLSession.shared.dataTask(with: TheUrls[index]) {(data, response, error) in
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    self.images = Image(uiImage: image)
                }
            } else {
                DispatchQueue.main.async {
                    self.images = Image(systemName: "multiply.circle")
                }
            }
        }.resume()
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
