//
//  SwimView.swift
//  sock
//
//  Created by Maarten Wittop Koning on 25/07/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//
import Foundation
import SwiftUI
import Combine
import URLImage
//
struct SwimView: View {
    @ObservedObject var fetcher = MovieFetcher()
    @State private var showModal = false
    var body: some View {
        NavigationView {
            VStack{
            List(fetcher.SwimWear) { movie in
                NavigationLink(destination:
                    VStack{ ModalView(img1:  movie.img_url.replacingOccurrences(of: "01j", with: "02i"), img:  movie.img_url_sec, img_sec:  movie.img_url
                        , name: movie.naam, price: movie.prijs )}
                    
                ) {
                VStack () {
                    URLImage(URL(string: movie.img_url)!, placeholder: Image("String"), content:  {
                       $0.image
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .clipped()
                       .padding(10)
                       .cornerRadius(20)
                       .frame(width: 350.0, height: 510.0)
                   })
                   .cornerRadius(20)
                    .shadow(radius: 11)
                    .overlay(Text(movie.naam)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .shadow(radius: 11)
                        .foregroundColor(Color.white))
                        .autocapitalization(.sentences)
                   .overlay(Text(movie.prijs)
                        .font(.title)
                    .padding(.bottom, 25.0)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 11)
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity, alignment: .bottom))
                    .navigationBarTitle(Text("SwimWear"))
                }
            }
        }
    }
}
    }

public class MovieFetcher: ObservableObject {

    @Published var SwimWear = [Linegerie]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/SwimWear.json")!
    
        URLSession.shared.dataTask(with: url) {(data,response,error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Linegerie].self, from: d)
                    DispatchQueue.main.async {
                        self.SwimWear = decodedLists
                    }
                }else {
                    print("No Data")
                }
            } catch {
                print ("Error with json decode",error)
            }
            
        }.resume()
         
    }
}
}
struct Linegerie: Codable, Identifiable {
    public var id = UUID()
    public var naam: String
    public var prijs: String
    public var img_url: String
    public var img_url_sec: String
    
    enum CodingKeys: String, CodingKey {
           case naam = "naam"
           case prijs = "prijs"
           case img_url = "img_url"
           case img_url_sec = "img_url_sec"
    }
}

struct SwimView_Previews: PreviewProvider {
    static var previews: some View {
        SwimView()
    }
}
