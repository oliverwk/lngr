import Foundation
import SwiftUI
import Combine
import URLImage
//
struct Lingerie: View {
    @ObservedObject var fetcher = MovieFetcher()
    

    var body: some View {
        NavigationView {
            VStack{
            List(fetcher.movies) { movie in
                ZStack {
                    NavigationLink(destination:
                        VStack{ ModalView(img1:  movie.img_url.replacingOccurrences(of: "01j", with: "02i"), img:  movie.img_url_sec, img_sec:  movie.img_url
                            , name: movie.naam, price: movie.prijs)}
                    ) {
                            VStack {
                            ZStack () {
                            URLImage(URL(string: movie.img_url)!, placeholder: Image("String"), content:  {
                               $0.image
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .clipped()
                               .cornerRadius(20)
                               .frame(width: 345.0, height: 525.0)
                           })
                           .cornerRadius(20)
                            .shadow(radius: 5)
                            .overlay(Text(movie.naam)
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .shadow(radius: 11)
                                .foregroundColor(Color.white))
                           .overlay(Text(movie.prijs)
                                .font(.title)
                                .padding(.bottom, 25.0)
                                 .shadow(radius: 11)
                                .foregroundColor(.secondary)
                                .frame(maxHeight: .infinity, alignment: .bottom))
                            }
                        }
                    }
                }.navigationBarTitle(Text("Lingerie"))
        }
    }
}
}
}

public class MovieFetcher: ObservableObject {

    @Published var movies = [Movie]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")!
    
        URLSession.shared.dataTask(with: url) {(data,response,error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Movie].self, from: d)
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

struct Movie: Codable, Identifiable {
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

struct Lingerie_Previews: PreviewProvider {
    static var previews: some View {
        Lingerie()
    }
}
