//
//  temp.swift
//  sock
//
//  Created by Maarten Wittop Koning on 12/01/2021.
//  Copyright © 2021 Olivier Wittop Koning. All rights reserved.
//

import SwiftUI

struct temp: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello world!")
            Button("Press Me!", action: {
            }) .padding([.leading, .bottom, .trailing], 20.0).buttonStyle(FilledButton())
                
        }
    }
}
struct FilledButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(8)
    }
}
struct temp_Previews: PreviewProvider {
    static var previews: some View {
        temp()
    }
}
