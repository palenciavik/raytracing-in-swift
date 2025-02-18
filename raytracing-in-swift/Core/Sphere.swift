import Foundation

struct Sphere {
    var center: Vec3
    var radius: Double

    // Returns the hit distance along the ray, or nil if no hit.
    func hit(ray: Ray) -> Double? {
        let oc = ray.origin - center
        let a = ray.direction.dot(ray.direction)
        let b = 2.0 * oc.dot(ray.direction)
        let c = oc.dot(oc) - radius * radius
        let discriminant = b * b - 4 * a * c
        if discriminant < 0 {
            return nil
        } else {
            // Return the nearest positive hit distance.
            let t = (-b - sqrt(discriminant)) / (2 * a)
            return t > 0 ? t : nil
        }
    }
}
