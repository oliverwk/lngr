import Foundation
import SwiftUI
import Combine

struct FetchView: View {
    @ObservedObject var fetcher = MovieFetcher()

    var body: some View {
        NavigationView {
            VStack{
            List(fetcher.movies) { movie in
                VStack (alignment: .leading) {
                    //Text(movie.name)
                   Image("tatiana_art_7")
                    .frame(width: 350.0, height: 350.0)
                    .cornerRadius(30)
                    .shadow(radius: 11)
                    .overlay(Text(movie.naam)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .shadow(radius: 11)
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading), alignment: .center)
                        
                    
                    
                    Text(movie.prijs)
                        .font(.system(size: 11))
                        .foregroundColor(Color.gray)
                }
            }
        }.navigationBarTitle(Text("Movies"))
        }
    }
}

 

public class MovieFetcher: ObservableObject {

    @Published var movies = [Movie]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "http://192.168.2.95/dk_2.json")!
    
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
    public var id: Int
    public var img_url: String
    public var naam: String
    public var prijs: String
    
    enum CodingKeys: String, CodingKey {
           case id = "1"
           case img_url = "title"
           case naam = "year"
           case prijs = "7.95"
    }
}

struct FetchView_Previews: PreviewProvider {
    static var previews: some View {
        FetchView()
    }
}
