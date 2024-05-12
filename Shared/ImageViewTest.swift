//
//  ImageViewTest.swift
//  lngr (iOS)
//
//  Created by Olivier Wittop Koning on 07/07/2023.
//

import SwiftUI
import VisionKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageViewTest: View {
    
    @State var image1: UIImage = UIImage(named: "04k")!
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size
       
       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height
       
       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }
       
       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       return newImage!
   }
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            Image(uiImage: image1)
                .scaledToFit()
                .onTapGesture {
                    if #available(iOS 16.0, *) {
                        print("HIIIIIII")
                        let interaction = ImageAnalysisInteraction()
                        UIImageView(image: UIImage(named: "04k")).addInteraction(interaction)
                        print(interaction.analysis.debugDescription)

 
                       /* Task {
                            let reqeust = VNGeneratePersonSegmentationRequest()
                            reqeust.outputPixelFormat = kCVPixelFormatType_OneComponent8
                            reqeust.qualityLevel = .accurate
                            
                            let TheSize = CGSizeMake(300.0, 300.0)
                            let foregroundcg = resizeImage(image: UIImage(named: "04k")!, targetSize: TheSize).cgImage!
                            
                            
                            let handler = VNImageRequestHandler(cgImage: foregroundcg)
                            
                            try handler.perform([reqeust])
                            
                            guard let result = reqeust.results?.first else {
                                return
                            }
                            
                            print(result)
                            
                            
                            let mask = CIImage(cvPixelBuffer: result.pixelBuffer)
                            let foreground = CIImage(cgImage: foregroundcg)
                            image1 = UIImage(ciImage: mask)
                            print(mask)
                            
         
                            // 3
                            let blendFilter = CIFilter.blendWithMask()
                            blendFilter.inputImage = foreground
                            blendFilter.backgroundImage = CIImage.empty()
                            blendFilter.maskImage = mask
                            
                            // 4
                            let resultImage = blendFilter.outputImage?.oriented(.up)
                            print(resultImage as Any)
                            image1 = UIImage(ciImage: resultImage!)

                            
                        }*/
                    } else {
                        // Fallback on earlier versions
                        
                    }
                }
        }
    }
    func convertCIImageToCGImage(_ inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        print("Eroor")
        return nil
    }
}

struct ImageViewTest_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewTest()
    }
}



public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
