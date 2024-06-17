//
//  ContentView.swift
//  OpenLocker WatchKit Extension
//
//  Created by Olivier Wittop Koning on 11/09/2021.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var Locker = LockerManager()
    
    var body: some View {
        TabView {
            VStack {
                    Text("849")
                        .font(.title)
                        .padding()
                        Button(action: Locker.open) {
                            Text("Open")
                                .fontWeight(.medium)
                                .foregroundColor(Color.green)
                        }.padding()
                    
                    ProgressView(value: Locker.secondsRemaining, total: 10.5)
                        .progressViewStyle(LinearProgressViewStyle(tint: $Locker.Colour.wrappedValue))
            }
            LingeriesView()
        }            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("Apple Watch SE - 40mm")
    }
}
