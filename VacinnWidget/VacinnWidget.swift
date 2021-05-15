//
//  vacinnWidget.swift
//  lngrWidgetExtension
//
//  Created by Olvier Wittop Koning on 10/04/2021.
//


import WidgetKit
import SwiftUI
import Combine

let OneVacinn = Vacinn(result: Selector(res: ["0","0","0"]))

struct Vacinn: Codable {
    public var result: Selector
    
    enum CodingKeys: String, CodingKey {
        case result = "result"
    }
}

struct Selector: Codable {
    public var res: [String]
    
    enum CodingKeys: String, CodingKey {
        case res = "vacs"
    }
}



struct Provider: TimelineProvider {
    static func getTheData(completion: ((Vacinn) -> Void)?) {
        let theSelctor = """
div[color=\\"data.primary\\"]
"""
        let urlString = "https://web.scraper.workers.dev/?url=https://coronadashboard.government.nl/landelijk/vaccinaties&selector=div%5Bcolor=%22data.primary%22%5D&pretty=true"
        let url: URL = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            //Parsing the json here
            guard error == nil, let content = data else {
                print("[ERROR] Error getting data from API")
                let response = OneVacinn
                completion?(response)
                return
            }
            let str = String(decoding: content, as: UTF8.self)
            let json = str.replacingOccurrences(of: theSelctor, with: "vacs")
            let jsonData: Data =  Data(json.utf8)
            print("[LOG] Parsing json from the data \(json as Any)")
            
            let lngrApiResponse: Vacinn
            do {
                lngrApiResponse = try JSONDecoder().decode(Vacinn.self, from: jsonData)
                print("[LOG] Parsing json from data")
            } catch {
                print("[ERROR] Error parsing json from data")
                let response = OneVacinn
                completion?(response)
                return
            }
            completion?(lngrApiResponse)
        }
        print("[LOG] Making the network requests")
        task.resume()
    }
    
    func placeholder(in context: Context) -> VacinnEntry {
        VacinnEntry(date: Date(), vacinn: OneVacinn)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (VacinnEntry) -> ()) {
        let entry = VacinnEntry(date: Date(), vacinn: OneVacinn)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("[LOG] Making the timeline")
        Provider.getTheData() { theVacinn in
            var entries: [VacinnEntry] = []
            var entry: VacinnEntry
            var components = DateComponents()
            components.hour = 15
            components.minute = 25
            let drieUur = Calendar.current.date(from: components)
            entry = VacinnEntry(date: Date(), vacinn: theVacinn)
            print("TheVacinn:", theVacinn)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .after(drieUur))
            
            //let timeline = Timeline(entries: entries, policy: .after(date: Date))
            completion(timeline)
        }
    }
}

struct VacinnEntry: TimelineEntry {
    let date: Date
    let vacinn: Vacinn
}

struct vacinnWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Text(String(entry.vacinn.result.res[1]).replacingOccurrences(of: ",", with: "."))
            .font(.title)
            .fontWeight(.heavy)
            .foregroundColor(Color.black)
    }
}

@main
struct vacinnWidget: Widget {
    let kind: String = "vacinnWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            vacinnWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("vacinn watcher")
        .description("Watch your lingerie right from your homescreen with the new lngr widget.")
        .supportedFamilies([.systemSmall])
    }
}

struct vacinnWidget_Previews: PreviewProvider {
    static var previews: some View {
        vacinnWidgetEntryView(entry: VacinnEntry(date: Date(), vacinn: OneVacinn))
            .previewContext(WidgetPreviewContext(family: .systemSmall)).preferredColorScheme(.light)
            .previewDevice("iPhone 8")
    }
}
