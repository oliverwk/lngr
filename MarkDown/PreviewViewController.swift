//
//  PreviewViewController.swift
//  MarkDown
//
//  Created by Olivier Wittop Koning on 30/06/2021.
//

import UIKit
import QuickLook
import WebKit

class PreviewViewController: UIViewController, QLPreviewingController, WKNavigationDelegate {
    enum MarkDownPreviewError: Error {
        case unableToOpenFile(atURL: URL)
    }
    var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = true
        view = webView
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
    
    func saveFile(str: String) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let fileName = "\(documentsDirectory)/tmp.html"
        
        do {
            try str.write(toFile: fileName, atomically: false, encoding: String.Encoding.utf8)
        } catch {
            print("Error \(error)")
        }
    }
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        // Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
        
        print("Hello from: preparePreviewOfFile")
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        
        
        let MarkDownData: Data
        let GithubUrl = URL(string: "https://api.github.com/markdown/raw")!
        var request = URLRequest(url: GithubUrl)
        request.allowsConstrainedNetworkAccess = true
        request.allowsExpensiveNetworkAccess = true
        do {
            MarkDownData = try Data(contentsOf: url)
            
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = MarkDownData
        } catch {
            print("Er was geen data uit het bestand: \(error.localizedDescription)")
            handler(MarkDownPreviewError.unableToOpenFile(atURL: url))
        }
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
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
        }.resume()
    }
    
}
