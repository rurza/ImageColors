//
//  ImageColorsTests.swift
//
//  Created by Adam Różyński on 12/08/2021.
//

import XCTest
@testable import ImageColors

final class ImageColorsTests: XCTestCase {

    func testExtractingColorsFromImage1() throws {
        let cgImage1 = cgImageForImageNamed("1")
        let colors1 = try cgImage1.extractColors()
        XCTAssertEqual(colors1.background.redComponent, 255.0/255)
        XCTAssertEqual(colors1.background.greenComponent, 246.0/255)
        XCTAssertEqual(colors1.background.blueComponent, 1.0/255)
        XCTAssertEqual(colors1.primary?.redComponent, 196.0/255)
        XCTAssertEqual(colors1.primary?.greenComponent, 97.0/255)
        XCTAssertEqual(colors1.primary?.blueComponent, 150.0/255)
        XCTAssertEqual(colors1.secondary?.redComponent, 160.0/255)
        XCTAssertEqual(colors1.secondary?.greenComponent, 14.0/255)
        XCTAssertEqual(colors1.secondary?.blueComponent, 240.0/255)
        XCTAssertNil(colors1.tertiary?.redComponent)
        XCTAssertNil(colors1.tertiary?.greenComponent)
        XCTAssertNil(colors1.tertiary?.blueComponent)
    }

    func testExtractingColorsFromImage2() throws {
        let cgImage2 = cgImageForImageNamed("2")
        let colors2 = try cgImage2.extractColors()
        XCTAssertEqual(colors2.background.redComponent, 52.0/255)
        XCTAssertEqual(colors2.background.greenComponent, 198.0/255)
        XCTAssertEqual(colors2.background.blueComponent, 88.0/255)
        XCTAssertEqual(colors2.primary?.redComponent, 26.0/255)
        XCTAssertEqual(colors2.primary?.greenComponent, 26.0/255)
        XCTAssertEqual(colors2.primary?.blueComponent, 26.0/255)
        XCTAssertEqual(colors2.secondary?.redComponent, 34.0/255)
        XCTAssertEqual(colors2.secondary?.greenComponent, 112.0/255)
        XCTAssertEqual(colors2.secondary?.blueComponent, 54.0/255)
        XCTAssertNil(colors2.tertiary?.redComponent)
        XCTAssertNil(colors2.tertiary?.greenComponent)
        XCTAssertNil(colors2.tertiary?.blueComponent)
    }

    func testExtractingColorsFromImage3() throws {
        let cgImage3 = cgImageForImageNamed("3")
        let colors3 = try cgImage3.extractColors()
        XCTAssertEqual(colors3.background.redComponent, 10.0/255)
        XCTAssertEqual(colors3.background.greenComponent, 122.0/255)
        XCTAssertEqual(colors3.background.blueComponent, 255.0/255)
        XCTAssertEqual(colors3.primary?.redComponent, 255.0/255)
        XCTAssertEqual(colors3.primary?.greenComponent, 204.0/255)
        XCTAssertEqual(colors3.primary?.blueComponent, 0.0/255)
        XCTAssertEqual(colors3.secondary?.redComponent, 100.0/255)
        XCTAssertEqual(colors3.secondary?.greenComponent, 210.0/255)
        XCTAssertEqual(colors3.secondary?.blueComponent, 255.0/255)
        XCTAssertNil(colors3.tertiary?.redComponent)
        XCTAssertNil(colors3.tertiary?.greenComponent)
        XCTAssertNil(colors3.tertiary?.blueComponent)
    }

    func testExtractingColorsFromImage4() throws {
        let cgImage4 = cgImageForImageNamed("4")
        let colors4 = try cgImage4.extractColors()
        XCTAssertEqual(colors4.background.redComponent, 255.0/255)
        XCTAssertEqual(colors4.background.greenComponent, 255.0/255)
        XCTAssertEqual(colors4.background.blueComponent, 255.0/255)
        XCTAssertEqual(colors4.primary?.redComponent, 8.0/255)
        XCTAssertEqual(colors4.primary?.greenComponent, 8.0/255)
        XCTAssertEqual(colors4.primary?.blueComponent, 8.0/255)
        XCTAssertEqual(colors4.secondary?.redComponent, 114.0/255)
        XCTAssertEqual(colors4.secondary?.greenComponent, 127.0/255)
        XCTAssertEqual(colors4.secondary?.blueComponent, 136.0/255)
        XCTAssertEqual(colors4.tertiary?.redComponent, 62.0/255)
        XCTAssertEqual(colors4.tertiary?.greenComponent, 69.0/255)
        XCTAssertEqual(colors4.tertiary?.blueComponent, 72.0/255)
    }

    func cgImageForImageNamed(_ name: String) -> CGImage {
        let image = Bundle.module.image(forResource: name)!
        return image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    }

}
