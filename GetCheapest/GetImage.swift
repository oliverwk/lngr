//
//  GetImage.swift
//  GetCheapest
//
//  Created by Olivier Wittop Koning on 06/07/2021.
//

import Foundation
import Intents

extension GetCheapestIntentHandler {
    /// Get's image from specifed url
    /// - Parameters:
    ///   - url: The Url to get the image from
    ///   - complete: A callback for the image
    /// - Returns: The Image Data
    func GetImage(url: URL, complete: @escaping ((Data?) -> ())) {
        logger.log("Getting image: \(url.absoluteString, privacy: .public)")
       
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let response = response as? HTTPURLResponse {
                logger.log("The respones was: \(response.debugDescription, privacy: .public)")
            }
            if let d = data {
                complete(d)
            } else if let error = error {
                if let response = response as? HTTPURLResponse {
                    logger.fault("[ERROR] Er was geen data met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public)")
                    complete(nil)
                } else {
                    logger.fault("[ERROR] Er was een terwijl de json werd geparsed: \(url, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                    complete(nil)
                }
            }
        }.resume()
    }
}
