import XCTest

final class RayTracerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testRenderedImageAppears() throws {
        let app = XCUIApplication()
        app.launch()
        
        let image = app.images.firstMatch
        let exists = image.waitForExistence(timeout: 10)
        XCTAssertTrue(exists, "The rendered image should appear within 10 seconds.")
    }
}
