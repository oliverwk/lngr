//
//  LingerieImageView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 04/03/2021.
//

import SwiftUI
import os


struct LingeriesImageView: View {
    var lngr: Lingerie
    
    var body: some View {
        AsyncImage(url: lngr.SecondImage) { image in
            image.resizable()
        } placeholder: {
            Image("01j").resizable()
        }
    }
}
