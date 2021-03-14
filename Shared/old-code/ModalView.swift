//
//  ModalView.swift
//  sock
//
//  Created by Maarten Wittop Koning on 25/07/2020.
//  Copyright © 2020 Olivier Wittop Koning. All rights reserved.
//

import SwiftUI


struct ModalView: View {
    var img1: String
    var img: String
    var img_sec: String
    var name: String
    var price: String
    var body: some View {
        // Spacer()
        ScrollView(.horizontal) {
            HStack(alignment: .center) {
                RemoteImage(url: img)
                    .aspectRatio(contentMode: .fit) // fill the frame
                    .clipped()                       // Clip overlaping parts
                RemoteImage(url: img_sec)
                    .aspectRatio(contentMode: .fit) // Fill the frame
                    .clipped()                       // Clip overlaping parts
                RemoteImage(url: img1)
                    .aspectRatio(contentMode: .fit) // Fill the frame
                    .clipped()                       // Clip overlaping parts
            }
            Text(price)
        }
        .navigationBarTitle(Text(name), displayMode: .inline)
    }
}


struct ModalView_Previews: PreviewProvider {
    static var previews: some View {
        ModalView(img1:"https://www.na-kd.com/resize/globalassets/nakd_boho_lace_thong_1013-000712-0002_01j.jpg",img:"https://www.na-kd.com/resize/globalassets/nakd_boho_lace_thong_1013-000712-0002_04k.jpg",img_sec:"https://www.na-kd.com/resize/globalassets/nakd_boho_lace_thong_1013-000712-0002_02i.jpg",name: "kanten string", price: "11.16")
    }
}
