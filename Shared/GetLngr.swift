//
//  GetLngr.swift
//  GetCheapest
//
//  Created by Olivier Wittop Koning on 14/06/2021.
//

import Foundation

func Getlngr(type: Lingeries, complete: @escaping ((Lingerie?) -> ()))  {
    logger.log("Getting urk for reqeust: lngr\(type.rawValue == 1 ? "Slips" : "Bodys")")
    let url = URL(string: (type.rawValue == 1 ? "https://raw.githubusercontent.com/oliverwk/wttpknng/master/Lingerie.json" : "https://raw.githubusercontent.com/oliverwk/wttpknng/master/bodys.json"))!
    URLSession.shared.dataTask(with: url) {(data, response, error) in
        do {
            if let d = data {
                let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                complete(decodedLists[0])
                
            } else if let error = error {
                if let response = response as? HTTPURLResponse {
                    logger.fault("[ERROR] Er was geen data met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    complete(nil)
                } else {
                    logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(url, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                    complete(nil)
                }
            }
        } catch {
            if let response = response as? HTTPURLResponse {
                logger.fault("[ERROR] Er was geen data met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                complete(nil)
            } else {
                logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(url, privacy: .public) met data \(String(decoding: data!, as: UTF8.self), privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                complete(nil)
            }
        }
    }.resume()
}

