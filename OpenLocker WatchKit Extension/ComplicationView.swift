//
//  ComplicationView.swift
//  OpenLocker WatchKit Extension
//
//  Created by Olivier Wittop Koning on 30/10/2021.
//

import SwiftUI
import ClockKit

struct ComplicationView: View {
    var body: some View {
        ZStack {
            Image(systemName: "lock")
                .font(.title3)
            Circle()
                .strokeBorder(Color.green, lineWidth: 3.5)
        }
    }
}

struct ComplicationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CLKComplicationTemplateGraphicCircularView(ComplicationView())
                .previewContext()
        }
    }
}
