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
            List(fetcher.movies) { movie in
                NavigationLink(destination:
                    VStack{ ModalView(img1:  movie.img_url.replacingOccurrences(of: "01j", with: "02i"), img:  movie.img_url.replacingOccurrences(of: "01j", with: "04k"), img_sec:  movie.img_url
                    , name: movie.naam)}
                    
                ) {
                VStack () {
                    URLImage(URL(string: movie.img_url)!, placeholder: Image("String"), content:  {
                       $0.image
                       .resizable()
                       .aspectRatio(contentMode: .fill)
                       .clipped()
                       .cornerRadius(20)
                       .frame(width: 350.0, height: 350.0)
                   })
                    //.onTapGesture {
                    //    self.showModal.toggle()
                      //             }
                   .cornerRadius(20)
                    .shadow(radius: 11)
                    .overlay(Text(movie.naam)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .shadow(radius: 11)
                        .foregroundColor(Color.white))
                   .overlay(Text(movie.prijs)
                        .font(.title)
                    .padding(.bottom, 15.0)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 11)
                        .foregroundColor(Color.gray)
                    .frame(maxHeight: .infinity, alignment: .bottom))
                        
                        
                    .sheet(isPresented: self.$showModal) {
                        Text(movie.img_url)
                    }
          
                }
            }.navigationBarTitle(Text("Slips"))
        }
    }
}
    }

public class MovieFetcher: ObservableObject {

    @Published var movies = [Linegerie]()
    
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
                        self.movies = decodedLists
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
    
    enum CodingKeys: String, CodingKey {
           case naam = "naam"
           case prijs = "prijs"
           case img_url = "img_url"
    }
}

struct SwimView_Previews: PreviewProvider {
    static var previews: some View {
        SwimView()
    }
}
