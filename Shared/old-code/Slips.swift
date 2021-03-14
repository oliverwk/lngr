import Foundation
import SwiftUI
import Combine

struct Slips: View {
    @ObservedObject var github = SlipFetcher()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(github.slips) { slip in
                    ZStack { //Dit is om de pijl weg te halen
                        NavigationLink(destination: LinkView(lingerie: slip)) {
                            EmptyView()
                        }.hidden()
                        RemoteImage(url: slip.img_url)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding(5.0)
                            .overlay(Text(slip.naam)
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                        .shadow(radius: 11)
                                        .foregroundColor(Color.white))
                            .overlay(Text(String(slip.prijs))
                                        .font(.title)
                                        .padding(.bottom, 25.0)
                                        .shadow(radius: 11)
                                        .foregroundColor(.secondary)
                                        .frame(maxHeight: .infinity, alignment: .bottom))
                    }
                }
            }.navigationBarTitle(Text("Slips"))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


public class SlipFetcher: ObservableObject {
    
    @Published var slips = [Lingerie]()
    
    init(){
        load()
    }
    
    func load() {
        let url = URL(string: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")!
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    DispatchQueue.main.async {
                        self.slips = decodedLists
                    }
                } else {
                    print("No Data")
                }
            } catch {
                print ("Error with json decode",error)
            }
            
        }.resume()
        
    }
}

struct Lingerie: Codable, Identifiable {
    public var id = UUID()
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    
    
    enum CodingKeys: String, CodingKey {
        case naam = "naam"
        case prijs = "prijs"
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
    }
}
