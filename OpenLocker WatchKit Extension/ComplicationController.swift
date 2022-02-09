//
//  ComplicationController.swift
//  OpenLocker WatchKit Extension
//
//  Created by Olivier Wittop Koning on 11/09/2021.
//

import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "isLockerOpen", displayName: "isMyLockerOpen", supportedFamilies: CLKComplicationFamily.allCases)
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        //        let templ = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "locked")!))
        
        //        let templ = CLKComplicationTemplateGraphicCircularClosedGaugeView(gaugeProvider: CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor.green, fillFraction: 1.0), label: ComplicationView())
        
        //        let templ = CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor.green, fillFraction: 1.0), imageProvider: CLKFullColorImageProvider(fullColorImage: UIImage(named: "locked")!))
        
        
        //        let tmp = CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: CLKGaugeProvider(style: .fill, gaugeColors: [UIColor.green], gaugeColorLocations: [10], start startDate: Date(), end endDate: Date(timeIntervalSince1970: Date().timeIntervalSince1970), centerTextProvider: CLKTextProvider(format: "40"))
        // OLD:        let templ = CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor.green, fillFraction: 1.0), centerTextProvider: CLKTextProvider(format: "C"))
        
        let templ =  CLKComplicationTemplateGraphicCircularView(ComplicationView())
        
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: templ)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler(nil)
    }
    
    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
}
