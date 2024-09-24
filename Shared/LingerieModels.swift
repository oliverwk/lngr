//
//  LingerieModels.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 01/06/2024.
//

import Foundation
import SwiftUI

/// Provides all information for the lingerie
struct Lingerie: Codable, Identifiable, CustomStringConvertible, Hashable {
    public var id: String
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    public var url: String
    public var kleur: String
    public var kleurFam: Array<KleurFamilie>
    public var isMatching: Bool = false
    public var beschrijving: String?
    public var sizesAvailable: Array<SizeFamilie>?
    public var materials: String?
    public var description: String {
        return "{ id: \(id), naam: \(naam), prijs: \(prijs), img_url: \(img_url), img_url_sec: \(img_url_sec), imageUrls: \(imageUrls), url: \(url), kleur: \(kleur) SecondImage: \(SecondImage), kleur: \(kleurFam), isMatching: \(isMatching)}"
    }
    
    public var SecondImage: URL {
        return URL(string: img_url_sec) ?? URL(string: "about:blank")!
    }
    
    public var kleurFamIds: [String] {
        var ks = [String]()
        for k in kleurFam {
            ks.append(k.id)
        }
        return ks
    }
    
    public var ImageURLS: Array<URL> {
        var ImageUrlS = [URL]()
        for url in imageUrls {
            ImageUrlS.append(URL(string: url)!)
        }
        return ImageUrlS
    }
    static let TheLingerie = Lingerie(id: "1-1013-000820-0138", naam: "Klassiek Katoenen String", prijs: 69.95, img_url:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg", img_url_sec:"https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg", imageUrls: [
        "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640",
        "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640",
        "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640",
        "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"
    ], url: "https://www.na-kd.com/nakd_classic_cotton_thong", kleur: "black", kleurFam: [KleurFamilie(id: "01094830958049238", naam: "Zwart", hex: "#000000", imgUrl: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640", URLS: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640")], sizesAvailable: [SizeFamilie(id: "1-1013-000820-0138", sizeName: "XS", price: Prices(current: 69.69, original: 69.95), stock: "LOW")])
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case prijs
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
        case kleurFam = "kleurFamilies"
        case beschrijving = "description"
        case materials
        case sizesAvailable
        case url
        case kleur
    }
}



/// Gives information about the one size of a lingerie item
struct SizeFamilie: Codable, Identifiable, CustomStringConvertible, Hashable {
    public var id: String
    public var sizeName: String
    public var price: Prices
    public var stock: String
    public var stockColor: Color {
        switch stock {
        case "high":
            return Color.blue
        case "low":
            return Color.orange
        case "":
            return Color.red
        default:
            return Color.black
        }
    }
    public var description: String {
        return "{ id: \(id), sizeName: \(sizeName), price: \(price), stock: \(stock) }"
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case sizeName
        case price
        case stock
    }
}

struct Prices: Codable, Hashable {
    let current, original: Double
}
    
/// Gives information about one color of a lingerie item
struct KleurFamilie: Codable, Identifiable, CustomStringConvertible, Hashable, Equatable {
   
    public var id: String
    public var naam: String
    public var hex: String
    public var imgUrl: String
    public var URLS: String
    public var url: URL {
        return URL(string: URLS) ?? URL(string: "about:blank")!
    }
    
    public var imgURL: URL {
        return URL(string: imgUrl) ?? URL(string: "about:blank")!
    }
    
    
    public var description: String {
        return "{ id: \(id), naam: \(naam), hex: \(hex), img_url: \(imgUrl), url: \(url), colour: \(colour)}"
    }
    
    public var colour: Color {
        let index1 = hex.index(hex.startIndex, offsetBy: 1)
        let hexColour = hex[index1...]
        
        let indexr = hexColour.index(hexColour.startIndex, offsetBy: 2)
        let red = UInt8(hexColour[..<indexr], radix: 16)
        let indexg = hexColour.index(hexColour.startIndex, offsetBy: 4)
        let green = UInt8(hexColour[indexr..<indexg], radix: 16)
        let indexb = hexColour.index(hexColour.startIndex, offsetBy: 6)
        let blue = UInt8(hexColour[indexg..<indexb], radix: 16)
        // print("rgb \(Double(red!)) \(Double(green!)) \(Double(blue!))")
        return Color(red: Double(red!) / 255, green: Double(green!) / 255, blue: Double(blue!) / 255)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case hex
        case imgUrl = "img_url"
        case URLS = "url"
    }
}

enum LngrType {
    case slip
    case bra
    case body
}

extension Color {
    public var muted: Color {
        return self.opacity(0.5)
        
    }
}

extension String {
    public var url: URL {
        return URL(string: self)!
        
    }
}

#if os(macOS)
import Cocoa

// Step 1: Typealias UIImage to NSImage
typealias UIImage = NSImage

// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)

        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }

}
#endif

