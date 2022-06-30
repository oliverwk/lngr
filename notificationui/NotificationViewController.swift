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
    var urls = [URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_01j.jpg?width=640"),
    URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_02i.jpg?width=640"),
    URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_03h.jpg?width=640"),
    URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=640")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
        logger.log("the view: \(self.view.debugDescription, privacy: .public)")
        colorSelector?.addTarget(self, action: #selector(colorSelectorTapped(sender:)), for: .valueChanged)
    }
    
    @objc func colorSelectorTapped(sender: UISegmentedControl) {
        self.notiImage?.image = UIImage(named: "String")
        
        let networkConnctions = true
        if networkConnctions {
            let task = URLSession.shared.dataTask(with: (self.urls[sender.selectedSegmentIndex] ?? URL(string: "https://www.na-kd.com/resize/globalassets/nakd_classic_cotton_thong-1013-000820-0138_04k.jpg?width=390"))!) {(data, response, error) in
                guard let data = data else { return }
                if (error != nil) {
                    self.logger.log("The error: \(error.debugDescription, privacy: .public)")
                } else {
                    self.logger.log("The res: \(response.debugDescription, privacy: .public)")
                    do {
                        self.notiImage?.image = UIImage(data: data)
                        self.label?.text = "\((Int((self.notiImage?.image!.size.width)!) / Int((self.notiImage?.image?.size.height)!))*390)"
                        self.logger.log("\((Int((self.notiImage?.image!.size.width)!) / Int((self.notiImage?.image?.size.height)!))*390)")
                    }
                }
            }
            task.resume()
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = (notification.request.content.userInfo["price"] as? String) ?? "€ 0.0"
        
        if let kleurFamilies = notification.request.content.userInfo["kleurFamilies"] as? Array<String> {
            for (i, kleur) in kleurFamilies.enumerated()  {
                colorSelector?.setTitle(kleur, forSegmentAt: i)
                logger.log("setTitle to \(kleur, privacy: .public) at \(i, privacy: .public)")
            }
            colorSelector?.selectedSegmentIndex = 3
        } else {
            logger.log("no kleurFamilies in userinfo")
        }
        
        if let notiImageData = notification.request.content.userInfo["notiImage"] as? Data {
            self.notiImage?.image = UIImage(data: notiImageData)
        } else {
            logger.log("no notiImageData in userinfo")
        }
        
        if let ImageURLS = notification.request.content.userInfo["ImageURLS"] as? Array<URL> {self.urls = ImageURLS}
    }

}
