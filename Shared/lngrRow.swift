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
            NavigationView {
                List {
                        ZStack {
                            lngrRow(TheLingerie: TheLingerie)
                            NavigationLink(destination: Text(TheLingerie.naam), tag: TheLingerie.id, selection: .constant("no id")) {
                                            EmptyView()
                            }.buttonStyle(PlainButtonStyle()).frame(width: 0, height: 0)
                        }
                    }.listStyle(.automatic).navigationBarTitle(Text("Slipjes")).navigationViewStyle(.stack)
                }
            NavigationView {
                List {
                    ZStack {
                            lngrRow(TheLingerie: TheLingerie)
                            NavigationLink(destination: Text("Hello")) {
                                            EmptyView()
                            }.buttonStyle(PlainButtonStyle()).hidden()
                        }
                }
            }
        }
        .previewDevice("iPhone 8")
    }
}
