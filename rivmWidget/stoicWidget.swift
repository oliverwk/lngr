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

struct stoicEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family: WidgetFamily
    
    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.qoute[1])
                .font(.headline)
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
        case .accessoryRectangular:
            if #available(iOSApplicationExtension 17.0, *) {
                ZStack {
                    AccessoryWidgetBackground()
                        .cornerRadius(5)
                    VStack {
                        Text(entry.qoute[1])
                            .font(.subheadline)
                        Text(entry.qoute[0])
                            .font(.caption)
                    }
                }
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
                .widgetAccentable()
                .containerBackground(for: .widget) { }
            } else {
                // Fallback on earlier versions
            }
            
        default: // This is for the .systemSmall
            if #available(iOSApplicationExtension 17.0, *) {
                VStack {
                    AccessoryWidgetBackground()
                    Text("\(entry.qoute[0])")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.pink)
                        .padding(4.0)
                        .widgetAccentable()
                    Text("\(entry.qoute[1])")
                        .font(.caption)
                        .padding(3.0)
                }
                .widgetURL(URL(string: "stoic-widget://\(entry.rndint)")!)
                .containerBackground(for: .widget) {
                    Color.white
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
}

struct stoicWidget: Widget {
    let kind: String = "stoicWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if  #available(iOSApplicationExtension 17.0, *) {
                stoicEntryView(entry: entry)
//                    .containerBackground(.fill.secondary, for: .widget)
            } else {
                stoicEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("stoic widget")
        .description("A new latin qoute every hour")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline])
    }
}

struct stoicWidget_Previews: PreviewProvider {
    static let SampleQoute = ["Verba volant,scripta manent", "Woorden vervliegen, het geschrevene blijft"]
    static var previews: some View {
        Group {
            stoicEntryView(entry: stoicEntry(date: Date(), rndint: 0, qoute: SampleQoute))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
        }
    }
}

