//
//  ImageColorsTests.swift
//
//  Created by Adam Różyński on 12/08/2021.
//

#if os(macOS)
import XCTest
@testable import ImageColors

final class ImageColorsTests: XCTestCase {

    func testExtractingColorsFromImage1() throws {
        let cgImage1 = cgImageForImageNamed("1")
        let colors1 = try cgImage1._extractColors()
        XCTAssertEqual(colors1.background.red, 255)
        XCTAssertEqual(colors1.background.green, 246)
        XCTAssertEqual(colors1.background.blue, 1)
        XCTAssertEqual(colors1.primary?.red, 201)
        XCTAssertEqual(colors1.primary?.green, 109)
        XCTAssertEqual(colors1.primary?.blue, 137)
        XCTAssertEqual(colors1.secondary?.red, 160)
        XCTAssertEqual(colors1.secondary?.green, 14)
        XCTAssertEqual(colors1.secondary?.blue, 240)
        XCTAssertNil(colors1.tertiary?.red)
        XCTAssertNil(colors1.tertiary?.green)
        XCTAssertNil(colors1.tertiary?.blue)
    }

    func testExtractingColorsFromImage2() throws {
        let cgImage2 = cgImageForImageNamed("2")
        let colors2 = try cgImage2._extractColors()
        XCTAssertEqual(colors2.background.red, 52)
        XCTAssertEqual(colors2.background.green, 198)
        XCTAssertEqual(colors2.background.blue, 88)
        XCTAssertEqual(colors2.primary?.red, 26)
        XCTAssertEqual(colors2.primary?.green, 26)
        XCTAssertEqual(colors2.primary?.blue, 26)
        XCTAssertEqual(colors2.secondary?.red, 34)
        XCTAssertEqual(colors2.secondary?.green, 112)
        XCTAssertEqual(colors2.secondary?.blue, 54)
        XCTAssertNil(colors2.tertiary?.red)
        XCTAssertNil(colors2.tertiary?.green)
        XCTAssertNil(colors2.tertiary?.blue)
    }

    func testExtractingColorsFromImage3() throws {
        let cgImage3 = cgImageForImageNamed("3")
        let colors3 = try cgImage3._extractColors()
        XCTAssertEqual(colors3.background.red, 10)
        XCTAssertEqual(colors3.background.green, 122)
        XCTAssertEqual(colors3.background.blue, 255)
        XCTAssertEqual(colors3.primary?.red, 255)
        XCTAssertEqual(colors3.primary?.green, 204)
        XCTAssertEqual(colors3.primary?.blue, 0)
        XCTAssertEqual(colors3.secondary?.red, 100)
        XCTAssertEqual(colors3.secondary?.green, 210)
        XCTAssertEqual(colors3.secondary?.blue, 255)
        XCTAssertNil(colors3.tertiary?.red)
        XCTAssertNil(colors3.tertiary?.green)
        XCTAssertNil(colors3.tertiary?.blue)
    }

    func testExtractingColorsFromImage4() throws {
        let cgImage4 = cgImageForImageNamed("4")
        let colors4 = try cgImage4._extractColors()
        XCTAssertEqual(colors4.background.red, 255)
        XCTAssertEqual(colors4.background.green, 255)
        XCTAssertEqual(colors4.background.blue, 255)
        XCTAssertEqual(colors4.primary?.red, 8)
        XCTAssertEqual(colors4.primary?.green, 8)
        XCTAssertEqual(colors4.primary?.blue, 8)
        XCTAssertEqual(colors4.secondary?.red, 141)
        XCTAssertEqual(colors4.secondary?.green, 154)
        XCTAssertEqual(colors4.secondary?.blue, 167)
        XCTAssertEqual(colors4.tertiary?.red, 79)
        XCTAssertEqual(colors4.tertiary?.green, 87)
        XCTAssertEqual(colors4.tertiary?.blue, 95)
    }

    func cgImageForImageNamed(_ name: String) -> CGImage {
        let image = Bundle.module.image(forResource: name)!
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    }

}
#endif
