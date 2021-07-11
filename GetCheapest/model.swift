//
//  model.swift
//  GetCheapest
//
//  Created by Olivier Wittop Koning on 11/06/2021.
//

import Foundation

struct Lingerie: Codable, Identifiable, CustomStringConvertible {
    public var id: String
    public var naam: String
    public var prijs: Double
    public var img_url: String
    public var img_url_sec: String
    public var imageUrls: [String]
    public var url: String
    public var kleur: String
    public var description: String {
        return "{ id: \(id), naam: \(naam), prijs: \(prijs), img_url: \(img_url), img_url_sec: \(img_url_sec), imageUrls: \(imageUrls), url: \(url) }"
    }
    
    public var Url: URL {
        return URL(string: self.url)!
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case naam
        case prijs
        case img_url = "img_url"
        case img_url_sec = "img_url_sec"
        case imageUrls = "imageUrls"
        case url
        case kleur
    }
}

extension Lingeries: CustomStringConvertible {
    public var description: String {
        self.rawValue == 1 ? "Slips" : (self.rawValue == 2 ? "Bras" : (self.rawValue == 3 ? "Bodys" : "Unknown"))
    }
    
    public var url: URL {
       return URL(string: (self.rawValue == 1 ? "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json" : (self.rawValue == 2 ? "https://raw.githubusercontent.com/oliverwk/wttpknng/master/bras.json" : (self.rawValue == 3 ? "https://raw.githubusercontent.com/oliverwk/wttpknng/master/bodys.json" : "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json")) ))!
    }
}
