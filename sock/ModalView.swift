//
//  ModalView.swift
//  sock
//
//  Created by Maarten Wittop Koning on 25/07/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//

import SwiftUI
import URLImage

struct ModalView: View {
    var img1: String
    var img: String
    var img_sec: String
    var name: String
    var body: some View {
       // Spacer()
        ScrollView(.horizontal) {
            HStack(alignment: .center) {
                URLImage(URL(string: img)!, placeholder: Image(systemName: "circle")){ proxy in
                proxy.image
                    .resizable()                     // Make image resizable
                    .aspectRatio(contentMode: .fill) // fill the frame
                    .clipped()                       // Clip overlaping parts
                }
                    URLImage(URL(string: img_sec)!, placeholder: Image(systemName: "circle")){ proxy in
                    proxy.image
                        .resizable()                     // Make image resizable
                        .aspectRatio(contentMode: .fill) // Fill the frame
                        .clipped()                       // Clip overlaping parts
                    }
                    URLImage(URL(string: img1)!, placeholder: Image(systemName: "circle")){ proxy in
                    proxy.image
                        .resizable()                     // Make image resizable
                        .aspectRatio(contentMode: .fill) // Fill the frame
                        .clipped()                       // Clip overlaping parts
                    }
                    .navigationBarTitle(Text("Tatiana"), displayMode: .inline)
            }
        }
            
            .navigationBarTitle(Text(name), displayMode: .inline)
    }
}
