//
//  Pixel
//
//  Created by Adam Różyński on 11/08/2021.
//

import Foundation

#if os(macOS)
import Cocoa
#else
import UIKit
#endif

public struct Pixel: Hashable, Equatable {

    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

#if os(iOS)
    public var uiColor: UIColor {
        UIColor(red: CGFloat(red)/CGFloat(UInt8.max),
                green: CGFloat(green)/CGFloat(UInt8.max),
                blue: CGFloat(blue)/CGFloat(UInt8.max),
                alpha: 1)
    }
#endif

#if os(macOS)
    public var nsColor: NSColor {
        NSColor(red: CGFloat(red)/CGFloat(UInt8.max),
                green: CGFloat(green)/CGFloat(UInt8.max),
                blue: CGFloat(blue)/CGFloat(UInt8.max),
                alpha: 1)
    }
#endif

    static var black: Self {
        .init(red: 0, green: 0, blue: 0)
    }

    static var white: Self {
        .init(red: .max, green: .max, blue: .max)
    }

    var isDarkColor: Bool {
        return (Double(red) * 0.2126) + (Double(green) * 0.7152) + (Double(blue) * 0.0722) < 127.5
    }

    var isBlack: Bool {
        return red < 23 && green < 23 && blue < 23
    }

    var isWhite: Bool {
        return red > 232 && green > 232 && blue > 232
    }

    var isBlackOrWhite: Bool {
        isBlack || isWhite
    }

    func isDistinct(_ other: Pixel) -> Bool {
        let red = Double(red)
        let green = Double(green)
        let blue = Double(blue)

        let otherRed = Double(other.red)
        let otherGreen = Double(other.green)
        let otherBlue = Double(other.blue)

        let distinctA = 63.75
        let distinctB = 7.65
        return (
            fabs(red - otherRed) > distinctA
            || fabs(green - otherGreen) > distinctA
            || fabs(blue - otherBlue) > distinctA
        )
        &&
        !(
            fabs(red - green) < distinctB
            && fabs(red - blue) < distinctB
            && fabs(otherRed - otherGreen) < distinctB
            && fabs(otherRed - otherBlue) < distinctB
        )
    }

    /// returns the HSB from RGB in form of (H: 0-360°, S: 0-100, B: 0-100)
    func toHSB() -> (hue: Int, saturation: Int, brightness: Int) {
        let red = Double(red) / Double(UInt8.max)
        let green = Double(green) / Double(UInt8.max)
        let blue = Double(blue) / Double(UInt8.max)

        var hue, saturation, brightness: Double

        let maximum = max(red, green, blue)
        let chroma = maximum - min(red, green, blue)

        // https://en.wikipedia.org/wiki/HSL_and_HSV#Lightness
        brightness = maximum

        // https://en.wikipedia.org/wiki/HSL_and_HSV#Saturation
        saturation = brightness == 0 ? 0 : chroma / brightness

        if chroma == 0 {
            hue = 0
        } else if maximum == red {
            hue = fmod((green - blue) / chroma, 6)
        } else if maximum == green {
            hue = 2 + (blue - red) / chroma
        } else {
            hue = 4 + (red - green) / chroma
        }

        if hue < 0 {
            hue += 6
        }

        let h = Int(round(hue * 60))
        let s = Int(round(saturation * 100))
        let b = Int(round(brightness * 100))

        return (hue: h, saturation: s, brightness: b)
    }

    // Ref: https://en.wikipedia.org/wiki/HSL_and_HSV
    func newWithSaturation(_ sat: Double) -> Self {

        let (h, s, b) = toHSB()
        // this algorithm works with HSB as H: 0...6, S: 0...1, B: 0...1)
        let hue = Double(h) / 60
        let saturation = Double(s) / 100
        let brightness = Double(b) / 100

        guard saturation >= sat else { return self }

        // Back to RGB
        let chroma = brightness * sat
        let secondLargestComponent = chroma * (1 - fabs(fmod(hue, 2) - 1))
        var newRed, newGreen, newBlue: Double

        switch hue {
        case 0...1:
            newRed = chroma
            newGreen = secondLargestComponent
            newBlue = 0
        case 1...2:
            newRed = secondLargestComponent
            newGreen = chroma
            newBlue = 0
        case 2...3:
            newRed = 0
            newGreen = chroma
            newBlue = secondLargestComponent
        case 3...4:
            newRed = 0
            newGreen = secondLargestComponent
            newBlue = chroma
        case 4...5:
            newRed = secondLargestComponent
            newGreen = 0
            newBlue = chroma
        case 5..<6:
            newRed = chroma
            newGreen = 0
            newBlue = secondLargestComponent
        default:
            newRed = 0
            newGreen = 0
            newBlue = 0
        }
        let match = brightness - chroma
        
        newRed = round((newRed + match) * 255)
        newGreen = round((newGreen + match) * 255)
        newBlue = round((newBlue + match) * 255)
        return Self(red: UInt8(newRed), green: UInt8(newGreen), blue: UInt8(newBlue))
    }

    func isContrastingTo(_ other: Self) -> Bool {
        let backgroundLuminosity = (0.2126 * Double(red))
        + (0.7152 * Double(green))
        + (0.0722 * Double(blue))
        + 12.75
        let foregroundLuminosity = (0.2126 * Double(other.red))
        + (0.7152 * Double(other.green))
        + (0.0722 * Double(other.blue))
        + 12.75

        if backgroundLuminosity > foregroundLuminosity {
            return backgroundLuminosity / foregroundLuminosity > 1.6
        } else {
            return foregroundLuminosity / backgroundLuminosity > 1.6
        }
    }
}
