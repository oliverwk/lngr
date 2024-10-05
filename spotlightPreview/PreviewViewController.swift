//
//  PreviewViewController.swift
//  spotlightPreview
//
//  Created by Olivier Wittop Koning on 22/06/2024.
//

import os
import UIKit
import CoreData
import QuickLook
import CoreSpotlight

class PreviewViewController: UIViewController, QLPreviewingController {
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "PreviewViewController"
    )
    
    @IBOutlet weak var imageStepper: UIStepper!
    @IBOutlet weak var colorSelector: UISegmentedControl!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var prijsLabel: UILabel!
    @IBOutlet weak var naamLabel: UILabel!
    var urls = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        colorSelector?.addTarget(self, action: #selector(colorSelectorTapped(sender:)), for: .valueChanged)
        imageStepper.addTarget(self, action: #selector(imageSelectorTappedStepper(sender:)), for: .valueChanged)
    }
    
    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     */
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.
       
        let lngrName = "SlipsIndexLngrs"
        let me = UserDefaults(suiteName: "lngrMeIndex")?.object(forKey: lngrName) as? [Lingerie] ?? [Lingerie]()
        naamLabel.text = "id: \(identifier), query: \(queryString ?? "niks gezocht") en the data from the UserDefaults: \(me)"
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
    
    @objc func colorSelectorTapped(sender: UISegmentedControl) async {
        print("Tapped index at colour: \(sender.selectedSegmentIndex)")
       // let data = fetchLngr(withId: self.lngr?.kleurFamIds?[sender.selectedSegmentIndex] ?? "1013-000820-0138")?.image ?? Data()
       // self.ImageView?.image = UIImage(data: data)
    }
    
    @objc func imageSelectorTappedStepper(sender: UIStepper) async {
        print("Tapped index at imageStepper: \(sender.value)")
        await getImage(url: self.urls[Int(sender.value)])
    }
    
    func HandleLngrData(_ lingr: LNGR) {
        let kleurFamilies = lingr.kleurFamIds ?? []
        if kleurFamilies.count > colorSelector?.numberOfSegments ?? 2 {
            for irs in 0...((kleurFamilies.count)-(colorSelector?.numberOfSegments ?? 2)) {
                colorSelector?.insertSegment(withTitle: "kleur \(irs)", at: irs + (colorSelector?.numberOfSegments ?? 2), animated: true)
            }
        }
        
        var i = 0
        for _ in lingr.kleurFamIds ?? [] {
          //  colorSelector?.setTitle(newKleur.naam ?? "Geen naam", forSegmentAt: i)
          //  logger.log("setTitle to \(newKleur.naam ?? "Geen naam", privacy: .public) at \(i, privacy: .public)")
          //  kleurFams.append(newKleur)
            i += 1
        }
        
        colorSelector?.selectedSegmentIndex = 0
        if kleurFamilies.count <= 1 {
            colorSelector?.setTitle("", forSegmentAt: 1)
            colorSelector?.isEnabled = false
        }
        
        
        self.ImageView?.layer.cornerRadius = 25
        //let data = fetchLngr(withId: self.lngr?.kleurFamIds?[0] ?? "1013-000820-0138")?.image ?? Data()
        //self.ImageView?.image = UIImage(data: data)
        
        self.prijsLabel?.text = "\(String(lingr.prijs))"
    }
    
    func HandleLingerieData(_ lingr: Lingerie) async {
        let kleurFamilies = lingr.kleurFam
        if kleurFamilies.count > colorSelector?.numberOfSegments ?? 2 {
            for irs in 0...((kleurFamilies.count)-(colorSelector?.numberOfSegments ?? 2)) {
                colorSelector?.insertSegment(withTitle: "kleur \(irs)", at: irs + (colorSelector?.numberOfSegments ?? 2), animated: true)
            }
        }
        
        var i = 0
        for kleur in kleurFamilies  {
            colorSelector?.setTitle(kleur.naam, forSegmentAt: i)
            logger.log("setTitle to \(kleur.naam, privacy: .public) at \(i, privacy: .public)")
            i += 1
        }
        colorSelector?.selectedSegmentIndex = 0
        if kleurFamilies.count <= 1 {
            colorSelector?.setTitle("", forSegmentAt: 1)
            colorSelector?.isEnabled = false
        }
        
        
        self.ImageView?.layer.cornerRadius = 25
        await getImage(url: lingr.SecondImage)
        imageStepper.maximumValue = Double(lingr.imageUrls.count)-1
        
        self.prijsLabel?.text = "\(String(lingr.prijs))"
        
    }
    
    func runSearch(_ text: String) {
        var allItems = [CSSearchableItem]()
        let queryString = "title == \"*\(text)*\"c"
        let CScontext = CSSearchQueryContext()
        CScontext.fetchAttributes = ["title", "contentDescription" , "contentURL", "thumbnailURL", "thumbnailData"]

        let searchQuery = CSSearchQuery(queryString: queryString, queryContext: CScontext)
        
        searchQuery.foundItemsHandler = { items in
            allItems.append(contentsOf: items)
        }
        
        searchQuery.completionHandler = { error in
            DispatchQueue.main.async {
                if allItems.count >= 1{
                    self.naamLabel.text = allItems[0].attributeSet.contentDescription ?? "hi"
                    self.ImageView.image = UIImage(data: allItems[0].attributeSet.thumbnailData ?? Data())
                }
            }
        }
        
        searchQuery.start()
    }
    
    func getImage(url: URL) async {
        self.ImageView?.image = UIImage(named: "String")
        logger.log("urls \(self.urls)")
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            DispatchQueue.main.async {
                self.ImageView?.image = UIImage(data: data)
                self.logger.log("\((Int((self.ImageView?.image!.size.width)!) / Int((self.ImageView?.image?.size.height)!))*390)")
            }
        } catch {
            self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url.absoluteString, privacy: .public) Met de error: \(String(describing: error), privacy: .public)")
        }
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
    
    func getLngr(id: String) async -> Lingerie? {
        // example id to use is 1013-001074-0015
        let searchUrl = URL(string: "https://www.na-kd.com/nl/search-page?q=\(id))")!
        let url = URL(string: "https://nkd_worker.wttp.workers.dev/getLngr/"+searchUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodeSet = try JSONDecoder().decode(Lingerie.self, from: data)
            return decodeSet
        } catch {
            self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url.absoluteString, privacy: .public) Met de error: \(String(describing: error), privacy: .public)")
            return nil
        }
    }
    
    /*func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
     
     // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
     
     // Perform any setup necessary in order to prepare the view.
     
     // Call the completion handler so Quick Look knows that the preview is fully loaded.
     // Quick Look will display a loading spinner while the completion handler is not called.
     handler(nil)
     }*/
    
}
