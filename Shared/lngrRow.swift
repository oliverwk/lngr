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
        LingerieImageView(lngr: TheLingerie)
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
        let TheLingerie = Lingerie(id: "01094830958049238", naam: "Klassiek Katoenen String", prijs: 69.95, img_url:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg", img_url_sec:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg", imageUrls: [
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640",
            "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"
        ], url: "https://www.na-kd.com/nakd_classic_cotton_thong", kleur: "black", kleurFam: [KleurFamilie(id: "01094830958049238", naam: "Zwart", hex: "#000000", imgUrl: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640", URLS: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640")])
        Group {
            NavigationStack {
                List {
                    NavigationLink(value: TheLingerie) {
                        lngrRow(TheLingerie: TheLingerie)
                    }
                    NavigationLink(value: TheLingerie) {
                        lngrRow(TheLingerie: TheLingerie)
                    }
                    
                }.listStyle(.automatic).navigationBarTitle(Text("Slipjes")).searchable(text: .constant(""))
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
