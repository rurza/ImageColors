    import XCTest
    @testable import ImageColors

    final class ImageColorsTests: XCTestCase {

        func testColorSaturation() {
            let pixel = Pixel(red: 255, green: 0, blue: 0)
            let new = pixel.withMinimalSaturation(0)
            XCTAssertEqual(new.red, 0)
            XCTAssertEqual(new.green, 0)
            XCTAssertEqual(new.blue, 0)
        }


    }
