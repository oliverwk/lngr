//
//  lingerie.swift
//  lngr (iOS)
//
//  Created by Maarten Wittop Koning on 07/03/2021.
//

import Foundation
import Combine

struct Lingerie: Codable, Identifiable {
    public var id = UUID()
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    
    
    enum CodingKeys: String, CodingKey {
        case naam = "naam"
        case prijs = "prijs"
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
    }
}
var OneLingerie = Lingerie(naam: "Klassiek Katoenen String",
                           prijs: 5.95,
                           img_url: "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_04k.jpg",
                           img_url_sec: "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_01j.jpg",
                           imageUrls: [
                            "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_04k.jpg?width=640",
                            "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_03h.jpg?width=640",
                            "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_02i.jpg?width=640",
                            "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_01j.jpg?width=640"
                           ])
func FetchLingerie() -> [Lingerie] {
    let data = """
        [
            {
                "naam": "Klassiek Katoenen String",
                "imageUrls": [
                    "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_04k.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_03h.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_02i.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_01j.jpg?width=640"
                ],
                "prijs": 5.95,
                "kleur": "Black",
                "kleurFamilies": [
                    "Black",
                    "Grey"
                ],
                "img_url": "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_04k.jpg",
                "img_url_sec": "https://www.na-kd.com/resize/globalassets/cotton_thong-1013-000820-0002_01j.jpg",
                "url": "https://www.na-kd.com/resize/nl/lingerie--nachtkleding/onderbroeken/strings/klassiek-katoenen-string-zwart",
                "kleurHex": null
            },
            {
                "naam": "Klassiek Katoenen String",
                "imageUrls": [
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"
                ],
                "prijs": 5.95,
                "kleur": "Grey Melange",
                "kleurFamilies": [
                    "Black",
                    "Grey"
                ],
                "img_url": "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg",
                "img_url_sec": "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg",
                "url": "https://www.na-kd.com/resize/nl/lingerie--nachtkleding/onderbroeken/strings/klassiek-katoenen-string-grijs",
                "kleurHex": "#ACA39E"
            },
            {
                "naam": "Kanten Slip",
                "imageUrls": [
                    "https://www.na-kd.com/resize/globalassets/nakd_retro_lace_edge_cheeky_panty_1013-000533-0260_01j-1.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_retro_lace_edge_cheeky_panty_1013-000533-0260_02i-1.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_retro_lace_edge_cheeky_panty_1013-000533-0260_03h-1.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_retro_lace_edge_cheeky_panty_1013-000533-0260_04k-1.jpg?width=640"
                ],
                "prijs": 5.95,
                "kleur": "Offwhite",
                "kleurFamilies": [
                    "White",
                    "Blue"
                ],
                "img_url": "https://www.na-kd.com/resize/globalassets/nakd_retro_lace_edge_cheeky_panty_1013-000533-0260_01j-1.jpg",
                "img_url_sec": "https://www.na-kd.com/resize/globalassets/nakd_retro_lace_edge_cheeky_panty_1013-000533-0260_04k-1.jpg",
                "url": "https://www.na-kd.com/resize/nl/lingerie--nachtkleding/onderbroeken/kanten-slip-wit",
                "kleurHex": null
            },
            {
                "naam": "Klassiek Katoenen Slip",
                "imageUrls": [
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_brief-1013-000819-0002_01j.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_brief-1013-000819-0002_02i.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_brief-1013-000819-0002_03h.jpg?width=640",
                    "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_brief-1013-000819-0002_03k.jpg?width=640"
                ],
                "prijs": 6.95,
                "kleur": "Black",
                "kleurFamilies": [
                    "Black"
                ],
                "img_url": "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_brief-1013-000819-0002_01j.jpg",
                "img_url_sec": "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_brief-1013-000819-0002_03k.jpg",
                "url": "https://www.na-kd.com/resize/nl/lingerie--nachtkleding/onderbroeken/slipjes/klassiek-katoenen-slip-zwart",
                "kleurHex": null
            }
        ]
        """.data(using: .utf8)!
    let decodedLists = (try? JSONDecoder().decode([Lingerie].self, from: data))!
    return decodedLists
}

