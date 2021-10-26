//
//  PreviewViewController.swift
//  MarkDown
//
//  Created by Olivier Wittop Koning on 30/06/2021.
//

import UIKit
import QuickLook
import SwiftUI
//import WebKit

class PreviewViewController: UIViewController, QLPreviewingController {
    enum MarkDownPreviewError: Error {
        case unableToOpenFile(atURL: URL)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
        
    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     *
     func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
     // Perform any setup necessary in order to prepare the view.
     
     // Call the completion handler so Quick Look knows that the preview is fully loaded.
     // Quick Look will display a loading spinner while the completion handler is not called.
     handler(nil)
     }
     */
    var markDownString: String = "H"
    @IBOutlet weak var TheText: UILabel!
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        print("Hello from: preparePreviewOfFile")
        do {
            print("Getting markdown from the file: \(url.absoluteString)")
            let MarkDownString = try String(contentsOf: url)
            self.markDownString = MarkDownString
            
            let childView = UIHostingController(rootView: Text(MarkDownString))
            addChild(childView)
            childView.view.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
            view.addSubview(childView.view)
            childView.didMove(toParent: self)
            
            handler(nil)
        } catch {
            print("Er was geen data uit het bestand: \(error.localizedDescription)")
            handler(MarkDownPreviewError.unableToOpenFile(atURL: url))
        }
    }
    
    
    
    @available(*, deprecated, message: "preparePreviewOfFileSSSSSSSSSS doesn't work ")
    func preparePreviewOfFileSSSSSSSSSS(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
        
        print("Hello from: preparePreviewOfFile")
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        
        do {
            let html = try String(contentsOf: url)
            
            print("Getting markdown")
/*            let down = Down(markdownString: MarkDownString)
            
            print("Making markdown to html")
            let html = try down.toHTML()*/
            
            print("Adding: \(html) to webview")
            //self.webView.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><style>* { font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Helvetica, Arial, sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\"; }</style></head><body><h1>SnapKit-LoginKit</h1><p>This example will show how to use snapchat's LoginKit with swiftui.</p><p>An API that changed in IOS 14 was how you handle url's as you see below this is the old way of doing it</p><pre><code class=\"language-swift\">import SCSDKLoginKit                func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -&gt; Bool {                    if SCSDKLoginClient.application(app, open: url, options: options) {return true}}</code></pre><p>While the new of doing things is this wich as you can see does not pass a <code>UIApplication</code> only a url as you can see below.</p> <pre><code class=\"language-swift\">ConentView().onOpenURL(perform: { url inprint(ulr)})</code></pre><p>So you need to pass it <code>UIApplication.shared</code> which does the trick.</p><pre><code class=\"language-swift\">ConentView().onOpenURL(perform: { url in if SCSDKLoginClient.application(UIApplication.shared, open: url, options: nil) { print(&quot;Nice, snapchat can read your url&quot;)} }) </code></pre></body></html>", baseURL: nil)
            //self.webView.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><style>* { font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Helvetica, Arial, sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\"; }</style></head><body>\(html)</body></html>", baseURL: nil)
        } catch {
            print("Er was geen data uit het bestand: \(error.localizedDescription)")
            handler(MarkDownPreviewError.unableToOpenFile(atURL: url))
        }
        
        /*URLSession.shared.dataTask(with: request) {(data, response, error) in
         guard let theResponse = (response as? HTTPURLResponse) else {
         print("No response")
         handler(MarkDownPreviewError.unableToOpenFile(atURL: url))
         return
         }
         
         guard 398 <= theResponse.statusCode else {
         print("Status code was \(theResponse.statusCode), but expected 200 with resone: \(request.debugDescription)")
         handler(MarkDownPreviewError.unableToOpenFile(atURL: url))
         return
         }
         
         if let d = data {
         print("De response was \(theResponse.debugDescription)\n\n")
         print("Got data: \(String(decoding: d, as: UTF8.self))")
         self.webView.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><style>* { font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Helvetica, Arial, sans-serif, \"Apple Color Emoji\", \"Segoe UI Emoji\"; }</style></head><body>\(String(decoding: d, as: UTF8.self))</body></html>", baseURL: nil)
         handler(nil)
         } else if let error = error {
         handler(MarkDownPreviewError.unableToOpenFile(atURL: url))
         print("[ERROR] Er was een bij het toevoegen aan de html met de error: \(error.localizedDescription) en met response: \(theResponse) en url: \(url.absoluteString)")
         }
         }.resume()*/
    }
    
}
