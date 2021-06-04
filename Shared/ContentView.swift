//
//  ContentView.swift
//  sock
//
//  Created by Olivier Wittop Koning on 09/05/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//


import Combine
import SwiftUI
import LocalAuthentication


struct ContentView: View {
    @State private var selection = 0
    @State private var blurRadius: CGFloat = 50.0
    private var authContext = LAContext()
    
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
        }.blur(radius: blurRadius)
        .onAppear(perform: {
            let reason = "Authenticate to go to lngr"
            authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                if success {
                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async {
                        self.blurRadius = 0.0
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")

                    // Fall back to a asking for username and password.
                    // ...
                }
            }
        })
    }
}

