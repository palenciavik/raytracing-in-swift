import XCTest
@testable import raytracing_in_swift

final class Vec3Tests: XCTestCase {
    func testAddition() {
        let v1 = Vec3(1, 2, 3)
        let v2 = Vec3(4, 5, 6)
        let result = v1 + v2
        XCTAssertEqual(result.x, 5)
        XCTAssertEqual(result.y, 7)
        XCTAssertEqual(result.z, 9)
    }
    
    // TODO:  further tests for subtraction, dot, cross, etc.
}

final class SphereTests: XCTestCase {
    func testSphereHit() {
        let sphere = Sphere(center: Vec3(0, 0, -1), radius: 0.5)
        let ray = Ray(origin: Vec3(0, 0, 0), direction: Vec3(0, 0, -1))
        let t = sphere.hit(ray: ray)
        XCTAssertNotNil(t, "The ray should hit the sphere.")
    }
    
    func testSphereMiss() {
        let sphere = Sphere(center: Vec3(0, 0, -1), radius: 0.5)
        let ray = Ray(origin: Vec3(0, 0, 0), direction: Vec3(1, 0, 0))
        XCTAssertNil(sphere.hit(ray: ray), "The ray should miss the sphere.")
    }
}
