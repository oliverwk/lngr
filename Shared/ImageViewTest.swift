//
//  ImageViewTest.swift
//  lngr (iOS)
//
//  Created by Olivier Wittop Koning on 07/07/2023.
//

import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageViewTest: View {
    @State var image1: UIImage = UIImage(named: "04k")!
    @State private var iss = 2
    private var processingQueue = DispatchQueue(label: "ProcessingQueue")
    private let options = [UIImage(named: "01j")!, UIImage(named: "02i")!, UIImage(named: "04k")!]
   
    
    var body: some View {
        VStack {
            HStack {
                Text("Hello, World!")
                Button("<") {
                    if ((iss-1) < 0) {
                        iss = 2
                        image1 = options[iss]
                    } else {
                        iss -= 1
                        image1 = options[iss]
                    }
                }
                Button(">") {
                    if ((iss+1) > 2) {
                        iss = 0
                        image1 = options[iss]
                    } else {
                        iss += 1
                        image1 = options[iss]
                    }
                }
            }
            
            Image(uiImage: image1)
                .scaledToFit()
                .onTapGesture {
                    if #available(iOS 17.0, *) {
                        
                        guard let inputImage = CIImage(image: UIImage(named: "04k")!) else {
                            print("Failed to create CIImage")
                            return
                        }
                        
                        processingQueue.async {
                            guard let maskImage = subjectMaskImage(from: inputImage) else {
                                print("Failed to create mask image")
                                return
                            }
                            let outputImage = apply(mask: maskImage, to: inputImage)
                            let image = render(ciImage: outputImage)
                            DispatchQueue.main.async {
                                image1 = image
                            }
                        }
                        
                        
                    } else {
                        // Fallback on earlier versions
                    }
                }
        }
    }
    @available(iOS 17.0, *)
    private func subjectMaskImage(from inputImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
            return nil
        }
        
        guard let result = request.results?.first else {
            print("No observations found")
            return nil
        }
        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            print(error)
            return nil
        }
    }
    
    private func apply(mask: CIImage, to image: CIImage) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage!
    }
    
    private func render(ciImage: CIImage) -> UIImage {
        guard let cgImage = CIContext(options: nil).createCGImage(ciImage, from: ciImage.extent) else {
            fatalError("Failed to render CGImage")
        }
        return UIImage(cgImage: cgImage)
    }
    
}

struct ImageViewTest_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewTest()
    }
}

