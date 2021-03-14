//
//  lngrWidget.swift
//  lngrWidget
//
//  Created by Olivier Wittop Koning on 06/03/2021.
//

import WidgetKit
import SwiftUI
import Combine

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), lingerie: OneLingerie)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), lingerie: OneLingerie)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
             URLSession.shared.dataTask(with: URL(string: "https://broken-tooth-1860.wttp.workers.dev/")!) {(data, response, error) in
             if let d = data {
                OneLingerie.naam = "\(d)"
                print("\(d)")
                let entry = SimpleEntry(date: entryDate, lingerie: OneLingerie)
                entries.append(entry)
             } else {
                OneLingerie.naam = "No Data"
                print("No Data")
                let entry = SimpleEntry(date: entryDate, lingerie: OneLingerie)
                entries.append(entry)
             }
         }.resume()
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let lingerie: Lingerie
}


struct lngrWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        Text(String(entry.lingerie.naam))
            .font(.title)
            .fontWeight(.heavy)
            .foregroundColor(Color.black)
    }
}

@main
struct lngrWidget: Widget {
    let kind: String = "lngrWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            lngrWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("lngr watcher")
        .description("Watch your lingerie right from your homescreen with the new lngr widget.")
    }
}

struct lngrWidget_Previews: PreviewProvider {
    static var previews: some View {
        lngrWidgetEntryView(entry: SimpleEntry(date: Date(), lingerie: OneLingerie))
            .previewContext(WidgetPreviewContext(family: .systemSmall)).preferredColorScheme(.light)
            .previewDevice("iPhone 8")
    }
}

