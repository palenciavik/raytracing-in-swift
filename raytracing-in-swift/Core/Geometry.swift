import Foundation

struct Vec3 {
    var x: Double
    var y: Double
    var z: Double
    
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    static func + (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    static func - (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    static func * (lhs: Vec3, rhs: Double) -> Vec3 {
        return Vec3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    
    static func * (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z)
    }
    
    func dot(_ other: Vec3) -> Double {
        return x * other.x + y * other.y + z * other.z
    }
    
    func cross(_ other: Vec3) -> Vec3 {
        return Vec3(
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        )
    }
    
    func length() -> Double {
        return sqrt(x * x + y * y + z * z)
    }
    
    func normalized() -> Vec3 {
        let len = length()
        return self * (1 / len)
    }
}

struct Ray {
    var origin: Vec3
    var direction: Vec3
    
    func at(_ t: Double) -> Vec3 {
        return origin + (direction * t)
    }
}

extension Vec3 {
    func rotate(around axis: Vec3, angle: Double) -> Vec3 {
        let cosTheta = cos(angle)
        let sinTheta = sin(angle)
        
        let x = (cosTheta + (1 - cosTheta) * axis.x * axis.x) * self.x +
                ((1 - cosTheta) * axis.x * axis.y - axis.z * sinTheta) * self.y +
                ((1 - cosTheta) * axis.x * axis.z + axis.y * sinTheta) * self.z
        
        let y = ((1 - cosTheta) * axis.y * axis.x + axis.z * sinTheta) * self.x +
                (cosTheta + (1 - cosTheta) * axis.y * axis.y) * self.y +
                ((1 - cosTheta) * axis.y * axis.z - axis.x * sinTheta) * self.z
        
        let z = ((1 - cosTheta) * axis.z * axis.x - axis.y * sinTheta) * self.x +
                ((1 - cosTheta) * axis.z * axis.y + axis.x * sinTheta) * self.y +
                (cosTheta + (1 - cosTheta) * axis.z * axis.z) * self.z
        
        return Vec3(x, y, z)
    }
}
