//
//  lngrRow.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 14/06/2021.
//

import SwiftUI

struct lngrRow: View {
    
    let TheLingerie: Lingerie
    let locale = Locale.current
    
    var body: some View {
        //        LingerieImageView(url: TheLingerie.img_url)
        LingeriesImageView(lngr: TheLingerie)
            .aspectRatio(contentMode: .fill)
            .cornerRadius(20)
        //.shadow(radius: 5)
            .padding(.vertical, 5.0)
            .overlay(Text(TheLingerie.naam)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .shadow(radius: 11)
                .foregroundColor(Color.white))
            .padding(3)
            .overlay(Text("\(locale.currencySymbol ?? "") \(String(TheLingerie.prijs))")
                .font(.title)
                .padding(.bottom, 25.0)
                .shadow(radius: 11)
                .foregroundColor(.secondary)
                .frame(maxHeight: .infinity, alignment: .bottom))
    }
}

struct lngrRow_Previews: PreviewProvider {
    static var previews: some View {
        let TheLingerie = Lingerie.TheLingerie
        Group {
            NavigationStack {
                List {
                    NavigationLink(value: TheLingerie) {
                        lngrRow(TheLingerie: TheLingerie)
                    }
                    NavigationLink(value: TheLingerie) {
                        lngrRow(TheLingerie: TheLingerie)
                    }
                    
                }
                .listStyle(.automatic)
                .navigationTitle(Text("Slipjes"))
                .searchable(text: .constant(""))
                .navigationDestination(for: Lingerie.self) { lngr in
                    LingerieView(lingerie: lngr)
                }
            }
            ZStack {
                lngrRow(TheLingerie: TheLingerie)
            }
        }
        .previewDevice("iPhone 8")
    }
}
