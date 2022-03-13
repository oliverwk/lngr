//
//  stoicWidget.swift
//  rivmWidgetExtension
//
//  Created by Olivier Wittop Koning on 28/02/2022.
//


import WidgetKit
import SwiftUI
import os

let stoicLogger = Logger(
    subsystem: "nl.wittopkoning.lngr.rivmWidget",
    category: "rivmWidget"
)

struct Provider: TimelineProvider {
    let SampleQoute = ["Verba volant,scripta manent", "Woorden vervliegen, het geschrevene blijft"]
    
    func placeholder(in context: Context) -> stoicEntry {
        stoicEntry(date: Date(), qoute: SampleQoute)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (stoicEntry) -> ()) {
        let entry = stoicEntry(date: Date(), qoute: SampleQoute)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [stoicEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 10 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let qoute = qoutes[Int.random(in: 0..<845)]
            let entry = stoicEntry(date: entryDate, qoute: qoute)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct stoicEntry: TimelineEntry {
    let date: Date
    let qoute: [String]
}

struct stoicEntryView : View {
    var entry: Provider.Entry
    // @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        VStack {
            Text("\(entry.qoute[0])")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.pink)
                .padding(4.0)
            Text("\(entry.qoute[1])")
                .font(.caption)
                .padding(3.0)
        }
    }
}

struct stoicWidget: Widget {
    let kind: String = "stoicWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            stoicEntryView(entry: entry)
        }
        .configurationDisplayName("stoic widget")
        .description("A new latin qoute every hour")
        .supportedFamilies([.systemSmall])
    }
}

struct stoicWidget_Previews: PreviewProvider {
    static let SampleQoute = ["Verba volant,scripta manent", "Woorden vervliegen, het geschrevene blijft"]
    static var previews: some View {
        Group {
            stoicEntryView(entry: stoicEntry(date: Date(), qoute: SampleQoute))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}

