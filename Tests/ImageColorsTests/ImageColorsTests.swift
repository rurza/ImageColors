    import XCTest
    @testable import ImageColors

    final class ImageColorsTests: XCTestCase {

        func testColorSaturation() {
            let redPixel = Pixel(red: 255, green: 0, blue: 0)
            var new = redPixel.newWithSaturation(0)
            XCTAssertEqual(new.red, 255)
            XCTAssertEqual(new.green, 255)
            XCTAssertEqual(new.blue, 255)

            new = redPixel.newWithSaturation(0.5)
            XCTAssertEqual(new.red, 255)
            XCTAssertEqual(new.green, 128)
            XCTAssertEqual(new.blue, 128)

            let cyan = Pixel(red: 0, green: 255, blue: 255)
            new = cyan.newWithSaturation(0.5)
            XCTAssertEqual(new.red, 128)
            XCTAssertEqual(new.green, 255)
            XCTAssertEqual(new.blue, 255)

        }

        func testHSBConversion() {
            let redPixel = Pixel(red: 255, green: 0, blue: 0)
            let redPixelHSB = redPixel.toHSB()
            XCTAssertEqual(redPixelHSB.hue, 0)
            XCTAssertEqual(redPixelHSB.saturation, 1)
            XCTAssertEqual(redPixelHSB.brightness, 1)

            let purplePixel = Pixel(red: 128, green: 128, blue: 255)
            let purplePixelHSB = purplePixel.toHSB()
            XCTAssertEqual(purplePixelHSB.hue, 240 / 60)
            XCTAssertEqual(Int(purplePixelHSB.saturation * 100), 49)
            XCTAssertEqual(purplePixelHSB.brightness, 1)

            let balticBlue = Pixel(red: 37, green: 77, blue: 120)
            let balticBlueHSB = balticBlue.toHSB()
            XCTAssertEqual(Int(balticBlueHSB.hue * 100), Int((211.0 / 60) * 100))
            XCTAssertEqual(Int(balticBlueHSB.saturation * 100), 69)
            XCTAssertEqual(Int(balticBlueHSB.brightness * 100), 47)
        }


    }
