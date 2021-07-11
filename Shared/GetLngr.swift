//
//  GetLngr.swift
//  GetCheapest
//
//  Created by Olivier Wittop Koning on 14/06/2021.
//

import Foundation

extension GetCheapestIntentHandler {
    /// Get the specifed lngr from github
    /// - Parameters:
    ///   - type: Which type of lngr to get
    ///   - complete: A callback with the Lingerie
    /// - Returns: Lingerie
    func Getlngr(type: Lingeries, complete: @escaping ((Lingerie?) -> ())) {
        logger.log("Getting url for reqeust: lngr \(type, privacy: .public)")
        URLSession.shared.dataTask(with: type.url) {(data, response, error) in
            do {
                if let d = data {
                    let decodedLists = try JSONDecoder().decode([Lingerie].self, from: d)
                    logger.log("The response of the lngr is good: \(decodedLists[0], privacy: .public)")
                    complete(decodedLists[0])
                } else if let error = error {
                    if let response = response as? HTTPURLResponse {
                        logger.fault("[ERROR] Er was geen data met het laden een url: \(type.url.absoluteString, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                        complete(nil)
                    } else {
                        logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(type.url.absoluteString, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                        complete(nil)
                    }
                }
            } catch {
                if let response = response as? HTTPURLResponse {
                    logger.fault("[ERROR] Er was geen data met het laden een url: \(type.url.absoluteString, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    complete(nil)
                } else {
                    logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(type.url.absoluteString, privacy: .public) met data \(String(decoding: data!, as: UTF8.self), privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                    complete(nil)
                }
            }
        }.resume()
    }
}
