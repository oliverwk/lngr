//
//  LingerieView.swift
//  lngr
//
//  Created by Olivier Wittop Koning on 05/03/2021.
//

import SwiftUI
import Combine
import os
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

struct LingerieView: View {
    var lingerie: Lingerie
    var isMatching: Bool
    let locale = Locale.current
    let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "LingerieView"
    )
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    @StateObject private var ImageFetcher: ImageFetchers
    
    @State var ImageIndex: Int = 0
    
    @State private var hasMatchingSet = false
    @State var matchingLngr: Lingerie?
    
    @State private var showExtraInformation = false
    @State var extraInformation: Lingerie?
    @State var goToWebsite: Bool = false
    @State var favoriteColor = KleurFamilie(id: "01094830958049238", naam: "zwart", hex: "#000000", imgUrl: "about:blank", URLS: "about:blank")
    @State var i = 0
    @State var screenHeight = 0.0
    
    var foregroundColourText: Color {
        if colorScheme == .dark && (favoriteColor.hex == "#000000" || favoriteColor.naam.lowercased() == "zwart") {
            return Color.white
        } else if colorScheme == .light && (favoriteColor.hex.uppercased() == "#FFFFFF" || favoriteColor.naam.lowercased().contains("wit")) {
            return Color.black
        } else if ImageFetcher.removeBackground {
            var hue: CGFloat  = 2.4
            var saturation: CGFloat = 0.5
            var brightness: CGFloat = 1.0
            var alpha: CGFloat = 1.0
#if os(iOS)
            UIColor(favoriteColor.colour).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
#endif
            return Color(hue: hue, saturation: saturation, brightness: brightness-0.5)
        } else {
            return favoriteColor.colour
        }
        //        (colorScheme == .dark && favoriteColor.hex == "#000000") ? Color.white : ((colorScheme == .light && favoriteColor.hex.uppercased() == "#FFFFFF") ? Color.black: ( ImageFetcher.removeBackground ? favoriteColor.colour.colorInvert() : favoriteColor.colour))
    }
    
    init(lingerie: Lingerie) {
        self.lingerie = lingerie
        self.isMatching = lingerie.isMatching
        _ImageFetcher = StateObject(wrappedValue: ImageFetchers(ImageUrls: lingerie.imageUrls))
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                favoriteColor.colour
                    .ignoresSafeArea()
                    .opacity(0.75)
                    .onAppear {
                        screenHeight = geo.size.height * 0.775
                    }
            }
            
            ScrollView {
                VStack {
                    //LingerieImageView(ImageUrls: lingerie.ImageURLS)
                    /* Dit hier boven is voor mac
                     dir hier onder is ios*/
                    ImageFetcher.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .cornerRadius(5)
                        .padding(10)
                        .frame(maxHeight: screenHeight)
                        .onLongPressGesture {
                            self.logger.log("Long pressed!")
                            goToWebsite = true
                        }
                    
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onEnded({ value in
                                if value.translation.width < 0 {
                                    // left
                                    ImageIndex -= 1
                                    ImageFetcher.index -= 1
                                    ImageFetcher.load()
                                } else if value.translation.width > 0 {
                                    // right
                                    ImageIndex += 1
                                    ImageFetcher.index += 1
                                    ImageFetcher.load()
                                } else {
                                    ImageIndex += 1
                                    ImageFetcher.index += 1
                                    ImageFetcher.load()
                                }
                            }))
                    
#if os(macOS)
                        .environmentObject(ImageFetcher)
#endif
                        HStack {
                            Text("\(locale.currencySymbol ?? "") \(String(lingerie.prijs))")
                                .foregroundColor(foregroundColourText)
                            ForEach(0...(ImageFetcher.TheImageUrls.count-1), id: \.self) { irs in
                                ZStack {
                                    // TODO: zorg er voor dat dit images preview worden
                                    Rectangle()
                                    //       .foregroundColor(ImageFetcher.index == irs ? favoriteColor.colour.muted : favoriteColor.colour)
                                        .foregroundColor(ImageFetcher.index == irs ? foregroundColourText.muted : foregroundColourText)
                                        .cornerRadius(5)
                                        .frame(width: ImageFetcher.TheImageUrls.count >= 6 ? 30 : 40, height: 30)
                                        .onTapGesture {
                                            ImageFetcher.index = irs
                                            ImageFetcher.load()
                                        }
                                }
                            }
                            Button {
                                showExtraInformation = true
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            .padding(.horizontal, 10.0)
                        }
                        .padding(.bottom, 10.0)
                        .padding(.horizontal, 10.0)
                        .popover(isPresented: $showExtraInformation) {
                            VStack(alignment: .leading) {
                                Text("Description: \n  \(extraInformation?.beschrijving ?? "Geen beschrijving gevonden")\n")
                                    .padding(.horizontal, 10.0)
                                Text("Materials: \n  \(extraInformation?.materials ?? "Geen materials gevonden")\n")
                                    .padding(.horizontal, 10.0)
                                Text("Sizes available:")
                                    .padding(.horizontal, 10.0)
                                ForEach(extraInformation?.sizesAvailable ?? []) {
                                    Text("  \($0.sizeName) | \($0.stock)")
                                        .foregroundColor($0.stockColor)
                                        .padding(.horizontal, 10.0)
                                }
                            }
                        }
                        .onAppear {
                            Task {
                                let sq = lingerie.url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                                let decodeSet = await GetExtraInfo(searchUrl: sq)
                                self.extraInformation = decodeSet
                            }
                        }
                        
                        
                        
                        Picker("What is your favorite color?", selection: $favoriteColor) {
                            ForEach(lingerie.kleurFam, id: \.self) {
                                Text($0.naam)
                                    .foregroundColor($0.colour)
                            }
                        }
                    
#if os(macOS)
                    .padding(.horizontal, 25)
#endif
                
            }
                    .onChange(of: favoriteColor) { newFavoriteColor in
                        logger.log("favoriteColor \(favoriteColor, privacy: .public)")
                        logger.log("\(favoriteColor.id, privacy: .public) == \(lingerie.id.split(separator: "-")[...3].joined(separator: "-"), privacy: .public)")
                        // Check if they have the same id, so they have the same colour, but reomve the last three characters, because that is the size
                        if (favoriteColor.id == lingerie.id.split(separator: "-")[...3].joined(separator: "-")) {
                            ImageFetcher.TheImageUrls = lingerie.imageUrls
                            logger.log("imgurl: \(lingerie.imageUrls, privacy: .public)")
                            ImageFetcher.index = 0
                            logger.log("Dit is de orginele lngr")
                        } else if (false) {
                            // TODO: Hier de huigde database zoek of de zelfde kleur er in zit
                            //                  } else if (lingeries.contains { $0.id == favoriteColor.id }) {
                            //                      let llngr = lingeries.filter { $0.id == favoriteColor.id }
                            //                      ImageFetcher.TheImageUrls = llngr[0].imageUrls
                            //                      ImageFetcher.index = 0
                            //                      print("Dit een andere lngr, maar hij zit wel in de huidige database")
                        } else {
                            ImageFetcher.TheImageUrls = [newFavoriteColor.imgUrl]
                            ImageFetcher.index = 0
                            getExtraImages(searchUrl: newFavoriteColor.url, imageFetcher: ImageFetcher)
                            Task {
                                let decodeSet = await GetExtraInfo(searchUrl: newFavoriteColor.URLS)
                                self.extraInformation = decodeSet
                            }
                            logger.log("Dit een andere lngr, waar wij geen info over hebben, dus nieuwe aan het halen zijn")
                        }
                        ImageFetcher.load()
                    }
                    .onAppear {
                        favoriteColor = self.lingerie.kleurFam[0]
                    }
                    .pickerStyle(.segmented)
                
#if os(iOS)
                .navigationBarTitle(lingerie.naam, displayMode: .inline)
#endif
                
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            ImageFetcher.removeBackground.toggle()
                        } label: {
                            Image(systemName: "rectangle.slash")
                        }
                    }
                    
                    if hasMatchingSet && !isMatching {
                        ToolbarItem(placement: .navigation) {
                            NavigationLink(value: matchingLngr) {
                                Button("", systemImage: "ellipsis.circle") {
#if os(macOS)
                                    ImageFetcher.changeList(lngrr: matchingLngr!)
#endif
                                }
                            }
                        }
                    }
                }
                .alert("Do you want to go to the website", isPresented: $goToWebsite) {
                    Button("Yes", role: .destructive) {
                        openURL(URL(string: lingerie.url)!)
                        goToWebsite = false
                    }
                    Button("No, thanks", role: .cancel) {
                        goToWebsite = false
                    }
                }
                .onAppear {
                    Task {
                        let matchingSets = await getMatchingSet(searchUrl: URL(string: lingerie.url)!)
                        if let matchingSet = matchingSets {
                            matchingLngr = matchingSet
                            matchingLngr?.isMatching = true
                            hasMatchingSet = true
                        }
                        
                    }
                }
            }
        }
    }
    
    func getExtraImages(searchUrl: URL, imageFetcher: ImageFetchers)  {
        let url = URL(string: "https://nkd_worker.wttp.workers.dev/getlngr/"+searchUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let d = data {
                    let decodeLngrs = try JSONDecoder().decode(Lingerie.self, from: d)
                    let decodeImageUrls = decodeLngrs.imageUrls.map { $0.replacingOccurrences(of: "?width=400", with: "") }
                    DispatchQueue.main.async {
                        imageFetcher.TheImageUrls = decodeImageUrls
                        ImageFetcher.index = 0
                    }
                } else if let error = error {
                    if let response = response as? HTTPURLResponse {
                        self.logger.fault("[ERROR] Er was geen data met het laden een url: \(searchUrl.absoluteString, privacy: .public) en met response: \(response, privacy: .public) \n Met de error: \(error.localizedDescription, privacy: .public) en data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                    }
                }
            } catch {
                if let response = response as? HTTPURLResponse {
                    self.logger.fault("[ERROR] Er was geen data met het laden een url: \(searchUrl.absoluteString, privacy: .public) en met response: \(response, privacy: .public) Met de error: \(error.localizedDescription, privacy: .public) met data: \n \(String(decoding: data!, as: UTF8.self), privacy: .public)")
                }
            }
        }.resume()
    }
    
    func GetExtraInfo(searchUrl: String) async -> Lingerie?  {
        let url = URL(string: "https://nkd_worker.wttp.workers.dev/getLngr/\(searchUrl)")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if String(decoding: data, as: UTF8.self) == "null" {
                return nil
            } else {
                let decodeSet = try JSONDecoder().decode(Lingerie.self, from: data)
                return decodeSet
            }
        } catch {
            self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url.absoluteString, privacy: .public) Met de error: \(String(describing: error), privacy: .public)")
            return nil
            
        }
    }
    
    func getMatchingSet(searchUrl: URL) async -> Lingerie? {
        let url = URL(string: "https://nkd_worker.wttp.workers.dev/getMatchingSet/"+searchUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if String(decoding: data, as: UTF8.self) == "null" {
                return nil
            } else {
                let decodeSet = try JSONDecoder().decode(Lingerie.self, from: data)
                return decodeSet
            }
            
        } catch {
            self.logger.fault("[ERROR] Er was geen data met het laden een url: \(url.absoluteString, privacy: .public) Met de error: \(String(describing: error), privacy: .public)")
            return nil
        }
    }
    
}


public class ImageFetchers: ObservableObject {
    private let logger = Logger(
        subsystem: "nl.wittopkoning.lngr",
        category: "ImageFetchers"
    )
    @Published var index: Int = 1
#if targetEnvironment(simulator)
    @Published var removeBackground: Bool = false
#elseif os(iOS)
    @Published var removeBackground: Bool = true
#endif
#if os(macOS)
    @Published var removeBackground: Bool = false
#endif
    
    @Published var image: Image = Image("04k")
    @Published var TheImageUrls: [String]
    private var processingQueue = DispatchQueue(label: "ProcessingQueue")
    
    func changeList(lngrr: Lingerie) {
        TheImageUrls = lngrr.imageUrls
        self.index = 0
    }
    
    public func 🚫() {
#if os(iOS)
        let genarator = UINotificationFeedbackGenerator()
        genarator.notificationOccurred(.error)
#endif
    }
    
    init(ImageUrls: [String]) {
        self.TheImageUrls = ImageUrls
        load()
    }
    
    func load() {
        //if self.index >= self.TheImageUrls.count {
        if self.index >= TheImageUrls.count {
            self.index = 0
        } else if self.index <= -1 {
            self.index = TheImageUrls.count - 1
        }
        self.logger.info("\(self.index, privacy: .public) >= \(self.TheImageUrls.count, privacy: .public):\(self.index >= self.TheImageUrls.count, privacy: .public) met url: \(self.TheImageUrls[self.index])!)")
        URLSession.shared.dataTask(with: URL(string: self.TheImageUrls[self.index])! ) {(d, response, error) in
            if let data = d {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if #available(iOS 17.0, *) {
#if os(macOS)
                                let nnsimage = NSImage(data: data)
                                self.image = Image(nsImage: nnsimage!)
#endif

#if os(iOS)
                            if self.removeBackground {
                                withAnimation {
                                    self.image = Image(uiImage: image)
                                }
                                guard let inputImage = CIImage(image: image) else {
                                    print("Failed to create CIImage")
                                    self.🚫()
                                    return
                                }
                                
                                self.processingQueue.async {
                                    guard let maskImage = self.subjectMaskImage(from: inputImage) else {
                                        print("Failed to create mask image")
                                        self.🚫()
                                        return
                                    }
                                    let outputImage = self.apply(mask: maskImage, to: inputImage)
                                    let image = self.render(ciImage: outputImage)
                                    DispatchQueue.main.async {
                                        withAnimation {
                                            self.image = Image(uiImage: image)
                                        }
                                    }
                                }
                                
                            } else {
                                withAnimation {
                                    self.image = Image(uiImage: image)
                                }
                            }
#endif
                        } else {

                            withAnimation {
#if os(iOS)
                                self.image = Image(uiImage: image)
#endif
#if os(macOS)
                                let nnsimage = NSImage(data: data)
                                self.image = Image(nsImage: nnsimage!)
#endif
                            }
                        }
                    }
                } else {
                    self.logger.error("[ERROR] Er was een error met het laden een afbeelding url nar UIImage: \(self.TheImageUrls[self.index], privacy: .public) Met de error: \(error.debugDescription, privacy: .public)")
                    self.🚫()
                }
            } else {
                if let response = response as? HTTPURLResponse {
                    self.logger.error("[ERROR] Er was een error met het laden een afbeelding url: \(self.TheImageUrls[self.index], privacy: .public) en met response: \(response) Met de error: \(error.debugDescription, privacy: .public)")
                    self.🚫()
                } else {
                    self.logger.error("[ERROR] Er was een error met het laden een afbeelding url: \(self.TheImageUrls[self.index], privacy: .public) Met de error: \(error.debugDescription, privacy: .public)")
                    self.🚫()
                }
                DispatchQueue.main.async {
                    self.🚫()
                    withAnimation {
                        self.image = Image(systemName: "multiply.circle")
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Background remove logic
#if os(iOS)
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
#endif
}

struct LingerieImageView: View {
    let TheImageUrls: [URL]
    @EnvironmentObject var imageFetchers: ImageFetchers
    
    public init(ImageUrls: [URL]) {
        self.TheImageUrls = ImageUrls
    }
    
    var body: some View {
        AsyncImage(url: URL(string: imageFetchers.TheImageUrls[imageFetchers.index])) { image in
            image.resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .cornerRadius(5)
                .padding(10)
                .frame(width: 500)
        } placeholder: {
            Image("01j").resizable()
        }
    }
}

struct LingerieView_Previews: PreviewProvider {
    static var lngr = Lingerie.TheLingerie
    static var previews: some View {
        NavigationStack {
            LingerieView(lingerie: lngr)
                .previewDevice("iPhone 12")
        }
    }
}


// MARK: - GetImagesColour
struct GetImagesColour: Codable, CustomStringConvertible {
    var description: String {
        return "{imageUrls: \(imageUrls), naam: \(naam) prijs: \(prijs), kleur: \(kleur), img_url: \(imgURL), url: \(url)}"
    }
    
    let imageUrls: [String]
    let naam, prijs, kleur: String
    let imgURL: String
    let url: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case imageUrls, naam, prijs, kleur
        case imgURL = "img_url"
        case url, id
    }
}
