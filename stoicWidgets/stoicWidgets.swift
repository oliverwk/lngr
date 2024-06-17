//
//  stoicWidgets.swift
//  stoicWidgets
//
//  Created by Maarten Wittop Koning on 14/06/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let SampleQoute = ["Verba volant,scripta manent", "Woorden vervliegen, het geschrevene blijft"]
    
    func placeholder(in context: Context) -> stoicEntry {
        stoicEntry(date: Date(), rndint: 0, qoute: SampleQoute)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (stoicEntry) -> ()) {
        let entry = stoicEntry(date: Date(), rndint: 0, qoute: SampleQoute)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [stoicEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 10 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let rndint = Int.random(in: 0..<845)
            let qoute = qoutes[rndint]
            let entry = stoicEntry(date: entryDate, rndint: rndint, qoute: qoute)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


struct stoicEntry: TimelineEntry {
    let date: Date
    let rndint: Int
    let qoute: [String]
}

struct stoicWidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.qoute[1])
                .font(.headline)
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
        case .accessoryRectangular:
            ZStack {
                VStack {
                    Text(entry.qoute[0])
                        .font(.caption)
                        .widgetAccentable()
                    Text(entry.qoute[1])
                        .font(.caption2)
                }
            }
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
                .containerBackground(for: .widget) { }
        case .accessoryCorner:
           Image(systemName: "doc.append")
                .font(.title2)
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
        case .accessoryCircular:
            Image(systemName: "doc.append")
                .font(.title2)
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
        default: // This is for the .systemSmall
                VStack {
                    AccessoryWidgetBackground()
                    Text("\(entry.qoute[0])")
                        .font(.subheadline)
                        .foregroundColor(Color.pink)
                        .widgetAccentable()
                    Text("\(entry.qoute[1])")
                        .font(.caption)
                }
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
                .containerBackground(for: .widget) {
                    Color.white
                }
        }
    }
}
@main
struct stoicWidgets: Widget {
    let kind: String = "stoicWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                stoicWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                stoicWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .accessoryCorner, .accessoryCircular])
    }
}

#Preview(as: .accessoryRectangular) {
    stoicWidgets()
} timeline: {
    stoicEntry(date: .now, rndint: 0, qoute: ["Verba volant,scripta manent", "Woorden vervliegen, het geschrevene blijft"])
    stoicEntry(date: .now, rndint: 1, qoute: ["Verba volant,scripta manent", "Woorden vervliegen, het geschrevene blijft"])
}
