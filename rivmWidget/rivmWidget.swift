//
//  vacinnWidget.swift
//  lngrWidgetExtension
//
//  Created by Olivier Wittop Koning on 10/04/2021.
//


import WidgetKit
import SwiftUI
import Combine
import os

let logger = Logger(
    subsystem: "nl.wittopkoning.lngr.rivmWidget",
    category: "rivmWidget"
)

let PlaceholderVacinn = Vacinn(result: Selector(result: ["0,758,417","5,276,345","0"]))
let ErrorVacinn = Vacinn(result: Selector(result: ["0","0","0"]))

struct Vacinn: Codable, CustomStringConvertible {
    public var result: Selector

    var description: String {
        return "{ result: \(result) }"
    }
    enum CodingKeys: String, CodingKey {
        case result = "result"
    }
}

struct Selector: Codable, CustomStringConvertible {
    public var result: [String]
    
    var VacinnsThisWeek: String {
        return result[1].replacingOccurrences(of: ",", with: ".")
    }
    
    var VacinnsToday: String {
        let formatter = NumberFormatter()
        let VacinnsWeek = (Int(result[0].replacingOccurrences(of: ",", with: "")) ?? 0)
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        let vacinnsToday = formatter.string(from: NSNumber(value: (VacinnsWeek / 7))) ?? "\((VacinnsWeek / 7))"
        return vacinnsToday
    }
    
    enum CodingKeys: String, CodingKey {
        case result = "vacs"
    }
    var description: String {
        return "results: [\(result)]"
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
        logger.log("[LOG] Getting the Data from: \(urlString, privacy: .public)")
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            
            guard error == nil, let content = data else {
                logger.fault("[ERROR] Error getting data from API")
                var response = ErrorVacinn
                response.result.result[0] = error?.localizedDescription ?? "0"
                completion?(response)
                return
            }
            let str = String(decoding: content, as: UTF8.self)
            let json = str.replacingOccurrences(of: theSelctor, with: "vacs")
            let jsonData: Data =  Data(json.utf8)
            logger.log("[LOG] Parsing json from the data \(json, privacy: .public)")
            
            let lngrApiResponse: Vacinn
            do {
                lngrApiResponse = try JSONDecoder().decode(Vacinn.self, from: jsonData)
                logger.log("[LOG] Parsing json from data")
            } catch {
                logger.fault("[ERROR] Error parsing json from data")
                var response = ErrorVacinn
                response.result.result[0] = error.localizedDescription
                completion?(response)
                return
            }
            completion?(lngrApiResponse)
        }
        logger.info("[LOG] Making the network requests")
        task.resume()
    }
    
    func placeholder(in context: Context) -> VacinnEntry {
        VacinnEntry(date: Date(), vacinn: PlaceholderVacinn)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (VacinnEntry) -> ()) {
        completion(.init(date: Date(), vacinn: PlaceholderVacinn))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        logger.info("[LOG] Making the timeline")
        var entries: [VacinnEntry] = []
        Provider.getTheData() { theVacinn in
            logger.info("[LOG] Got the Data: \(theVacinn, privacy: .public)")
            var entry: VacinnEntry
            var components = DateComponents()
            components.hour = 15
            components.minute = 40
            components.second = 0
            components.nanosecond = 0
            let drieUur = Calendar.current.date(from: components)!
            logger.debug("[LOG] Adding the widget at: \(drieUur, privacy: .public)")
            entry = VacinnEntry(date: Date(), vacinn: theVacinn)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .atEnd)//.after(drieUur))
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
        VStack(alignment: .leading, spacing: 2) {
            Text("Vacinns")
                .fontWeight(.semibold)
            Text(entry.vacinn.result.VacinnsThisWeek)
                .font(.title2)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
            Text("+ \(entry.vacinn.result.VacinnsToday)")
                .fontWeight(.regular)
                .foregroundColor(.green)
        }
        .widgetURL(URL(string: "vacinn-widget://rivm")!)
    }
}

@main
struct vacinnWidget: Widget {
    let kind: String = "rivmWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            vacinnWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vacinn Watcher")
        .description("Watch the vacinns from your homescreen with the new vacinn widget.")
        .supportedFamilies([.systemSmall])
    }
}

struct vacinnWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            vacinnWidgetEntryView(entry: VacinnEntry(date: Date(), vacinn:  Vacinn(result: Selector(result: ["1,458,417","14,075,575","0"]))))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice("iPhone 7")
            vacinnWidgetEntryView(entry: VacinnEntry(date: Date(), vacinn:  Vacinn(result: Selector(result: ["1,458,417","14,075,575","0"]))))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice("iPhone 7")
        }
    }
}
