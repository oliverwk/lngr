//
//  LockerManager.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 11/09/2021.
//

import Foundation
import SwiftUI
import Combine
import os


public class LockerManager: ObservableObject {
    @Published var IsOpen = false
    @Published var secondsRemaining = 0.0
    @Published var Colour = Color.green
    
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr.OpenLocker",
        category: "LockerManager"
    )
    
    /// Helper function to porvide user feedback when somthing has gone wrong
    public func simpleError() {
        WKInterfaceDevice.current().play(.failure)
        logger.log("simpleError")
    }
    
    public func simpleSuccess() {
        WKInterfaceDevice.current().play(.success)
        logger.log("simpleSuccess")
    }
    
    
    
    func open() -> Void {
        let timestamp = Int64(round(Date().timeIntervalSince1970*1000) - 30000)
        let url = URL(string: "https://mapi.releezme.net/api/Lockers/9960a1c9-bc66-4d61-b00d-c4e4701cc019/Open?nocache=\(timestamp)")!
        
        var request = URLRequest(url: url)
        var token = ProcessInfo.processInfo.environment["Reelzme_API_KEY"] ?? "No Token"
        if token == "No Token" {
            logger.debug("No token was found in the environment, so searching in the file")
            if let filepath = Bundle.main.path(forResource: ".env", ofType: "txt") {
                do {
                    let contents = try String(contentsOfFile: filepath).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    logger.log("The token found in the file: \(contents, privacy: .private(mask: .hash))")
                    token = "\(contents)"
                } catch {
                    logger.debug("No content (including the token) was found in the file and the environment")
                    self.simpleError()
                    logger.fault("There was no token found for the reqeust: \(ProcessInfo.processInfo.environment.debugDescription, privacy: .public)")
                    return
                }
            } else {
                logger.debug("No token was found in the environment and the file was überhaupt not found")
                self.simpleError()
                logger.fault("There was no token found for the reqeust: \(ProcessInfo.processInfo.environment.debugDescription, privacy: .public)")
                return
            }
        }
        
        logger.log("The token is: \(token, privacy: .private(mask: .hash))")
        request.allHTTPHeaderFields = ["authorization":"Bearer \(token)", "api-version":"3", "content-length":"0", "user-agent":"Mozilla/5.0 (iPhone; CPU iPhone OS 14_2_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E149"]
        request.httpMethod = "POST"
        
        logger.log("Making reqeust to: \(url.absoluteString, privacy: .public)")
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            do {
                let TheStatus = try JSONDecoder().decode(LockerOpened.self, from: data!)
                if TheStatus.status.isOk {
                    self.simpleSuccess()
                    for second in 0...20 {
                        let seconds = second/2
                        if seconds <= 3 {
                            self.logger.debug("(seconds <= 3) Setting color to yellow")
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(seconds)) {
                                withAnimation {
                                    self.secondsRemaining += 0.5
                                }
                            }
                        } else if seconds <= 5 && seconds >= 3 {
                            self.logger.debug("(seconds <= 5) Setting color to yellow")
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(seconds)) {
                                withAnimation {
                                    self.Colour = Color.yellow
                                    self.secondsRemaining += 0.5
                                }
                            }
                        } else if seconds < 8 && seconds >= 3 {
                            self.logger.debug("(seconds < 8) Setting color to orange")
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(seconds)) {
                                withAnimation {
                                    self.Colour = Color.orange
                                    self.secondsRemaining += 0.5
                                }
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + Double(seconds)) {
                                self.logger.debug("(else) Setting color to red")
                                withAnimation {
                                    self.Colour = Color.red
                                    self.secondsRemaining += 0.5
                                }
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
                        withAnimation {
                            self.Colour = Color.green
                            self.secondsRemaining = 0.0
                        }
                    }
                } else {
                    self.simpleError()
                    self.logger.log("The reqeust wasn't ok")
                    if let response = response as? HTTPURLResponse {
                        self.logger.fault("[ERROR] The reqeust wasn't ok met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    } else {
                        self.logger.fault("[ERROR] The reqeust wasn't ok : \(url, privacy: .public) met data \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    }
                }
            } catch {
                self.simpleError()
                if let response = response as? HTTPURLResponse {
                    print("ERR:", error)
                    self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                } else {
                    self.logger.fault("[ERROR] Er was een error terwijl de json werd geparsed: \(url, privacy: .public) met data \(String(decoding: data!, as: UTF8.self), privacy: .public) Met de error: \(error.localizedDescription, privacy: .public)")
                }
            }
        }.resume()
    }
}


struct LockerOpened: Codable, Identifiable, CustomStringConvertible, Hashable {
    public var id = UUID()
    public var status: Status
    public var description: String {
        return "{ Status: \(status) }"
    }
    
    enum CodingKeys: String, CodingKey {
        case status = "Status"
    }
}

struct Status: Codable, Identifiable, CustomStringConvertible, Hashable {
    public var id = UUID()
    public var Code: Int
    public var TechnicalMessage: String
    public var isOk: Bool {
        if TechnicalMessage == "OK" {
            return true
        } else {
            return false
        }
    }
    public var description: String {
        return "{ Code: \(Code), TechnicalMessage: \(TechnicalMessage) }"
    }
    
    enum CodingKeys: String, CodingKey {
        case Code
        case TechnicalMessage
    }
}
