//
//  ContentView.swift
//  sock
//
//  Created by Maarten Wittop Koning on 09/05/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//


import Combine
import SwiftUI

struct ContentView: View {
    @State private var selection = 0

 

    var body: some View {
        TabView(selection: $selection){
                SwimView()
                .tabItem {
                    VStack {
                        Image(systemName: "house")
                        Text("Lingerie")
                    }
                }
                .tag(0)

        Lingerie()
           .tabItem {
               VStack {
                   Image(systemName: "rectangle.3.offgrid")
                   Text("SwimWear")
               }
           }
           .tag(1)
        }
    }
}
//
              //   .edgesIgnoringSafeArea(.top)
               
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

