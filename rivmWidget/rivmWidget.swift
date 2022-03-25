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

let PlaceholderVacinn = Vacinn(result: Selector(result: ["81.6%", "85.6%", "81.7%", "13,320,388", "91%"]))
let ErrorVacinn = Vacinn(result: Selector(result: ["00.0%","00.0%","00.0%","00.0%","00.0%"]))

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
    static let regexNumber = try! NSRegularExpression(pattern: "[1-9]")
    
    var VacinnsThisWeek: String {
        return result[1].replacingOccurrences(of: ",", with: ".")
    }
    
    var VacinnsToday: String {
        let formatter = NumberFormatter()
        var vacinnsToday: String
        let VacinnsWeek = (Int(result[0].replacingOccurrences(of: ",", with: "")) ?? 0)
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        logger.log("res: \(result[0].prefix(2) + "." + result[0].suffix(2).prefix(1))")
        logger.log("res1: \(result[1].prefix(2) + "." + result[1].suffix(2).prefix(1))")
        if (Selector.regexNumber.firstMatch(in: result[1], options: [], range: NSRange(location: 0, length: result[1].utf16.count)) == nil)  {
            logger.log("There was an error, because there aren't any numbers in result[1] \(result[1], privacy: .public) so not doing any thing with the result")
            vacinnsToday = "null" //result[1]
        } else {
            let num = (Float(result[0].prefix(2) + "." + result[0].suffix(2).prefix(1))! - Float(result[1].prefix(2) + "." + result[1].suffix(2).prefix(1))!)
            vacinnsToday = (formatter.string(from: NSNumber(value: num)) ?? "\((VacinnsWeek))")+"%"
        }
        return vacinnsToday
    }
    
    enum CodingKeys: String, CodingKey {
        case result = "vacs"
    }
    var description: String {
        return "results: [\(result)]"
    }
}


struct provider: TimelineProvider {
    static func getTheData(completion: ((Vacinn) -> Void)?) {
        let theSelctor = """
div[color=\\"data.primary\\"]
"""
        let urlString = "https://web.scraper.workers.dev/?url=https://coronadashboard.government.nl/landelijk/vaccinaties&selector=div%5Bcolor=%22data.primary%22%5D&pretty=true"
        let url: URL = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        logger.log("[LOG] Getting the Data from: \(urlString, privacy: .public)")
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if (error != nil) {
                logger.fault("[ERROR] Error getting data from API: \(error.debugDescription)")
                var response = ErrorVacinn
                response.result.result[1] = error?.localizedDescription ?? "Geen data bij het reqeust"
                completion?(response)
                return
            }
            guard let content = data else {
                logger.fault("[ERROR] Error getting data from API")
                var response = ErrorVacinn
                response.result.result[1] = error?.localizedDescription ?? "Geen data bij het reqeust"
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
                response.result.result[1] = error.localizedDescription
                completion?(response)
                return
            }
            completion?(lngrApiResponse)
        }
        logger.info("[LOG] Making the network requests")
        task.resume()
    }
    
    func placeholder(in context: Context) -> VacinnEntry {
        return VacinnEntry(date: Date(), vacinn: PlaceholderVacinn)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (VacinnEntry) -> ()) {
        completion(VacinnEntry(date: Date(), vacinn: PlaceholderVacinn))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        logger.info("[LOG] Making the timeline")
        var entries: [VacinnEntry] = []
        provider.getTheData() { theVacinn in
            logger.info("[LOG] Got the Data: \(theVacinn, privacy: .public)")
            var entry: VacinnEntry
            var components = DateComponents()
            components.hour = 15
            components.minute = 55
            components.second = 0
            components.nanosecond = 0
            let drieUur = Calendar.current.date(from: components)!
            logger.debug("[LOG] Adding the widget at: \(drieUur, privacy: .public)")
            entry = VacinnEntry(date: drieUur, vacinn: theVacinn)
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
    var entry: provider.Entry
    
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
struct lngrWidgets: WidgetBundle {
    var body: some Widget {
        vacinnWidget()
        stoicWidget()
    }
}

struct vacinnWidget: Widget {
    let kind: String = "rivmWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: provider()) { entry in
            vacinnWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Vacinn Watcher")
        .description("Watch the vacinns from your homescreen.")
        .supportedFamilies([.systemSmall])
    }
}

struct vacinnWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            vacinnWidgetEntryView(entry: VacinnEntry(date: Date(), vacinn:  Vacinn(result: Selector(result: ["105,000", "85.6%", "81.7%", "13,320,388", "91%"]))))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDevice("iPhone 7")
            vacinnWidgetEntryView(entry: VacinnEntry(date: Date(), vacinn:  Vacinn(result: Selector(result: ["105,000", "85.6%", "81.7%", "13,320,388", "91%"]))))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDevice("iPhone 7")
        }
    }
}
