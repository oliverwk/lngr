//
//  ContentView.swift
//  sock
//
//  Created by Olivier Wittop Koning on 09/05/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//


import Combine
import SwiftUI


struct ContentView: View {
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection){
            Lingeries(Url: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json", title: "Slips")
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("test")
                    }
                }
                .tag(0)
            
            Lingeries(Url: "https://raw.githubusercontent.com/oliverwk/wttpknng/master/bodys.json", title: "Bodys")
                .tabItem {
                    VStack {
                        Image(systemName: "rectangle.3.offgrid")
                        Text("Bodys")
                    }
                }
                .tag(1)
        }
    }
}

