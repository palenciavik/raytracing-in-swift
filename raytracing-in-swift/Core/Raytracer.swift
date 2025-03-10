import Foundation

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

func rayColor(ray: Ray) -> Vec3 {
    // Define a sphere in the scene.
    let sphere = Sphere(center: Vec3(0, 0, -1), radius: 0.5)
    
    if let t = sphere.hit(ray: ray) {
        let hitPoint = ray.at(t)
        let normal = (hitPoint - sphere.center).normalized()
        // Map the normal from [-1, 1] to [0, 1] for RGB.
        return (normal + Vec3(1,1,1)) * 0.5
    }
    
    let unitDirection = ray.direction.normalized()
    let t = 0.5 * (unitDirection.y + 1.0)
    return Vec3(1.0, 1.0, 1.0) * (1.0 - t) + Vec3(0.5, 0.7, 1.0) * t
}

func generateImage(width: Int, height: Int, camera: Camera) -> PlatformImage {
    let size = CGSize(width: width, height: height)

    #if canImport(UIKit)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { context in
        let cgContext = context.cgContext
        renderPixels(width: width, height: height, cgContext: cgContext)
    }
    #elseif canImport(AppKit)
    let image = NSImage(size: size)
    image.lockFocus()
    guard let cgContext = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    renderPixels(width: width, height: height, cgContext: cgContext)
    image.unlockFocus()
    return image
    #endif
}

func renderPixels(width: Int, height: Int, camera: Camera, cgContext: CGContext) {
    let aspectRatio = Double(width) / Double(height)
    let camera = Camera(aspectRatio: aspectRatio)
    
    for j in 0..<height {
        for i in 0..<width {
            let u = Double(i) / Double(width - 1)
            let v = Double(j) / Double(height - 1)
            
        	let ray = camera.getRay(u: u, v: v)
            let color = rayColor(ray: ray)
            
            let r = CGFloat(color.x)
            let g = CGFloat(color.y)
            let b = CGFloat(color.z)
            
            cgContext.setFillColor(CGColor(red: r, green: g, blue: b, alpha: 1.0))
            cgContext.fill(CGRect(x: i, y: height - j - 1, width: 1, height: 1))
        }
    }
}
