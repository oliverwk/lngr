//
//  NotificationViewController.swift
//  notificationui
//
//  Created by Olivier Wittop Koning on 29/06/2022.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import os

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "NotificationViewController"
    )
    
    @IBOutlet var label: UILabel?
    @IBOutlet weak var notiImage: UIImageView?
    @IBOutlet weak var colorSelector: UISegmentedControl?
    @IBOutlet weak var imageStepper: UIStepper!
    
    var urls = [URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640"),
                URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640"),
                URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640"),
                URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640")]
    var kleurFams = [KleurFamilie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        logger.log("the view: \(self.view.debugDescription, privacy: .public)")
        colorSelector?.addTarget(self, action: #selector(colorSelectorTapped(sender:)), for: .valueChanged)
        imageStepper.addTarget(self, action: #selector(imageSelectorTappedStepper(sender:)), for: .valueChanged)
    }
    
    func getImage(url: URL) {
        self.notiImage?.image = UIImage(named: "String")
        let networkConnctions = true
        if networkConnctions {
            logger.log("urls \(self.urls)")
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                if (error != nil) {
                    self.logger.log("The error: \(error.debugDescription, privacy: .public)")
                } else {
                    let code = (response as? HTTPURLResponse)?.statusCode
                    self.logger.log("The res: \(code ?? 0, privacy: .public)")
                    DispatchQueue.main.async {
                        self.notiImage?.image = UIImage(data: data)
                        self.logger.log("\((Int((self.notiImage?.image!.size.width)!) / Int((self.notiImage?.image?.size.height)!))*390)")
                    }
                }
            }
            task.resume()
        }
    }
                                                  
    @objc func colorSelectorTapped(sender: UISegmentedControl) {
        print("Tapped index at colour: \(sender.selectedSegmentIndex)")
        getImage(url: self.kleurFams[sender.selectedSegmentIndex].imgURL)
        Task {
            print("Dit een andere lngr, waar wij geen info over hebben, dus nieuwe aan het halen zijn")
            self.urls = await getExtraImages(searchUrl: self.kleurFams[sender.selectedSegmentIndex].url) ?? []
            imageStepper.maximumValue = Double(self.urls.count)-1
        }
    }
    
    @objc func imageSelectorTappedStepper(sender: UIStepper) {
        print("Tapped index at imageStepper: \(sender.value)")
        getImage(url: (self.urls[Int(sender.value)] ?? URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640"))!)
    }

    func getExtraImages(searchUrl: URL) async -> [URL]? {
        let url = URL(string: "https://nkd_worker.wttp.workers.dev/getImagesColour/"+searchUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodeSet = try JSONDecoder().decode([String].self, from: data)
            var ImageUrlS = [URL]()
            for url in decodeSet {
                ImageUrlS.append(URL(string: url)!)
            }
            return ImageUrlS
        } catch {
            self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url.absoluteString, privacy: .public) Met de error: \(String(describing: error), privacy: .public)")
            return nil
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        if let kleurFamiliesData = notification.request.content.userInfo["kleurFamilies"] as? String {
            let kleurFamilies = try? JSONDecoder().decode([KleurFamilie].self, from: Data(kleurFamiliesData.utf8))
            self.kleurFams = kleurFamilies ?? []
            var i = 0
            if kleurFamilies?.count ?? 1 > colorSelector?.numberOfSegments ?? 2 {
                for irs in 0...((kleurFamilies?.count ?? 1)-(colorSelector?.numberOfSegments ?? 2)) {
                    colorSelector?.insertSegment(withTitle: "kleur \(irs)", at: irs + (colorSelector?.numberOfSegments ?? 2), animated: true)
                }
            }
            
            for kleur in kleurFamilies ?? []  {
                colorSelector?.setTitle(kleur.naam, forSegmentAt: i)
                logger.log("setTitle to \(kleur.naam, privacy: .public) at \(i, privacy: .public)")
                i += 1
            }
            colorSelector?.selectedSegmentIndex = 0
        } else {
            logger.log("no kleurFamilies in userinfo")
        }
        
        self.notiImage?.layer.cornerRadius = 25
        if let notiImageData = notification.request.content.userInfo["notiImage"] as? Data {
            self.notiImage?.image = UIImage(data: notiImageData)
        } else {
            logger.log("no notiImageData in userinfo")
        }
        self.notiImage?.layer.cornerRadius = 25
        if let ImageURLS = notification.request.content.userInfo["ImageURLS"] as? Array<String> {
            var ImageUS = [URL]()
            for url in ImageURLS {
                ImageUS.append(URL(string: url)!)
            }
            self.urls = ImageUS
            imageStepper.maximumValue = Double(self.urls.count)-1
        } else {
            logger.log("no imageURLS in userinfo")
        }
        
        if let price = notification.request.content.userInfo["price"] as? String {
            self.label?.text = price
        } else {
            logger.log("no price in userinfo")
            self.label?.text = "€ 0.0"
        }
        
    }
    
}
