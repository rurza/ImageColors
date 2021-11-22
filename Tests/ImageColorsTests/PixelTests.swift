    import XCTest
    @testable import ImageColors

    final class PixelTests: XCTestCase {

        func testColorSaturation() throws {
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

        func testHSBConversion() throws {
            let redPixel = Pixel(red: 255, green: 0, blue: 0)
            let redPixelHSB = redPixel.toHSB()
            XCTAssertEqual(redPixelHSB.hue, 0)
            XCTAssertEqual(redPixelHSB.saturation, 100)
            XCTAssertEqual(redPixelHSB.brightness, 100)

            let purplePixel = Pixel(red: 128, green: 128, blue: 255)
            let purplePixelHSB = purplePixel.toHSB()
            XCTAssertEqual(purplePixelHSB.hue, 240)
            XCTAssertEqual(purplePixelHSB.saturation, 50)
            XCTAssertEqual(purplePixelHSB.brightness, 100)

            let balticBlue = Pixel(red: 37, green: 77, blue: 120)
            let balticBlueHSB = balticBlue.toHSB()
            XCTAssertEqual(balticBlueHSB.hue, 211)
            XCTAssertEqual(balticBlueHSB.saturation, 69)
            XCTAssertEqual(balticBlueHSB.brightness, 47)
        }

        func testDistinctColor() throws {
            let redPixel = Pixel(red: 255, green: 0, blue: 0)
            XCTAssertFalse(redPixel.isDistinct(.init(red: 250, green: 0, blue: 0)))
            XCTAssertTrue(redPixel.isDistinct(.init(red: 255, green: 255, blue: 0)))
            XCTAssertTrue(redPixel.isDistinct(.init(red: 255, green: 0, blue: 255)))
        }


    }
