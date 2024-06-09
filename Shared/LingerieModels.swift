//
//  LingerieModels.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 01/06/2024.
//

import Foundation

import SwiftUI



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
    public var description: String {
        return "{ id: \(id), naam: \(naam), prijs: \(prijs), img_url: \(img_url), img_url_sec: \(img_url_sec), imageUrls: \(imageUrls), url: \(url), kleur: \(kleur) }"
    }
    public var SecondImage: URL {
        return URL(string: img_url_sec) ?? URL(string: "about:blank")!
    }
    
    public var ImageURLS: Array<URL> {
        var ImageUrlS = [URL]()
        for url in imageUrls {
            ImageUrlS.append(URL(string: url)!)
        }
        return ImageUrlS
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case prijs
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
        case kleurFam = "kleurFamilies"
        case url
        case kleur
    }
}

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
        return "{ id: \(id), naam: \(naam), hex: \(hex), img_url: \(imgUrl), url: \(url)}"
    }
    
    public var mutedColour: Color {
        return colour.opacity(0.5)
        
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
