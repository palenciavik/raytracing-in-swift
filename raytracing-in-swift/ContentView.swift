import SwiftUI

struct ContentView: View {
    @State private var image: PlatformImage?
    
    var body: some View {
        VStack {
            if let image = image {
            #if canImport(UIKit)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            #elseif canImport(AppKit)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            #endif
            }
            else {
                Text("Rendering...")
            }
        }
        .onAppear{
            DispatchQueue.global(qos: .userInitiated).async {
                let renderedImage = generateImage(width: 200, height: 200)
                DispatchQueue.main.async {
                    self.image = renderedImage
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
