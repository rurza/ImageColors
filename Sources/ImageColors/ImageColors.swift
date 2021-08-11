//
//
//  Created by Adam Różyński on 09/08/2021.
//  based on
//  https://github.com/jathu/UIImageColors
//  by Jathu Satkunarajah (@jathu)
//

import Accelerate
import CoreGraphics

#if os(macOS)
import Cocoa
public typealias ImageColor = NSColor
#else
import UIKit
import XCTest
public typealias ImageColor = UIColor
#endif

public enum ImageColorsError: Error {
    case imageResizeError(vImage_Error)
}

public struct ImageColors {
    public var background: ImageColor
    public var primary: ImageColor
    public var secondary: ImageColor
    public var detail: ImageColor
}

public enum ImageExtractQuality: CGFloat {
    case lowest = 50
    case low = 100
    case medium = 200
    case high = 300
    case original = 0

    func newSize(from size: CGSize) -> CGSize {
        if size.width < size.height {
            let ratio = CGFloat(size.height) / CGFloat(size.width)
            return CGSize(width: self.rawValue / ratio, height: self.rawValue)
        } else {
            let ratio = CGFloat(size.width) / CGFloat(size.height)
            return CGSize(width: self.rawValue, height: self.rawValue / ratio)
        }
    }
}

struct Pixel: Hashable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8

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

    var imageColor: ImageColor {
        return ImageColor(red: CGFloat(red/UInt8.max),
                          green: CGFloat(green/UInt8.max),
                          blue: CGFloat(blue/UInt8.max),
                          alpha: 1)
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

    func toHSB() -> (hue: Double, saturation: Double, brightness: Double) {
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

        return (hue: hue, saturation: saturation, brightness: brightness)
    }

    // Ref: https://en.wikipedia.org/wiki/HSL_and_HSV
    func newWithSaturation(_ sat: Double) -> Self {

        let (hue, saturation, brightness) = toHSB()

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

private struct ImageColorsCounter: Comparable, Equatable {
    let color: Pixel
    let count: Int

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.count < rhs.count
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.count == rhs.count
    }
}

public extension CGImage {

    func extractColors(withQuality quality: ImageExtractQuality = .original) throws -> ImageColors {
        let expectedImageFormat = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: [CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                         CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
                         CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)],
            renderingIntent: .defaultIntent
        )!

        // Image format
        let sourceImageFormat = vImage_CGImageFormat(cgImage: self)!
        let sourceBuffer = try vImage_Buffer(cgImage: self)
        defer { sourceBuffer.free() }

        var destinationImageFormatBuffer = try vImage_Buffer(width: width,
                                                             height: height,
                                                             bitsPerPixel: expectedImageFormat.bitsPerPixel)
        defer { destinationImageFormatBuffer.free() }
        let imageFormatConverter = try vImageConverter.make(sourceFormat: sourceImageFormat,
                                                            destinationFormat: expectedImageFormat)

        try imageFormatConverter.convert(source: sourceBuffer, destination: &destinationImageFormatBuffer)

        // Scale the image
        let newSize = quality.newSize(from: CGSize(width: width, height: height))
        var destinationSizeBuffer = try vImage_Buffer(width: Int(newSize.width),
                                                      height: Int(newSize.height),
                                                      bitsPerPixel: expectedImageFormat.bitsPerPixel)
        defer { destinationSizeBuffer.free() }
        let error = vImageScale_ARGB8888(&destinationImageFormatBuffer,
                                         &destinationSizeBuffer,
                                         nil,
                                         vImage_Flags(kvImageHighQualityResampling))
        guard error == kvImageNoError else { throw ImageColorsError.imageResizeError(error) }

        // Analyze pixels
        let capacity = destinationSizeBuffer.rowBytes * Int(destinationSizeBuffer.height)
        let data = destinationSizeBuffer.data.bindMemory(to: UInt8.self, capacity: capacity)
        defer { data.deinitialize(count: capacity) }

        let width = Int(destinationSizeBuffer.width)
        let height = Int(destinationSizeBuffer.height)

        var imageColors: Dictionary<Pixel, Int> = [:]

        for x in 0 ..< width {
            for y in 0 ..< height {
                // 4 for as the numer of channels
                let pixel: Int = Int(destinationSizeBuffer.rowBytes) * y + x * 4
                let alpha = data[pixel]
                if 50 <= alpha { // magic alpha number
                    let red = data[pixel+1]
                    let green = data[pixel+2]
                    let blue = data[pixel+3]
                    imageColors[Pixel(red: red, green: green, blue: blue), default: 0] += 1
                }
            }
        }

        let threshold = Int(CGFloat(height) * 0.01)
        var sortedColors: [ImageColorsCounter] = imageColors.keys
            .compactMap { pixel in
                let count = imageColors[pixel]!
                if count > threshold {
                    return ImageColorsCounter(color: pixel, count: count)
                } else {
                    return nil
                }
            }
            .sorted(by: <)

        var edgeColor: ImageColorsCounter
        if let first = sortedColors.first {
            edgeColor = first
        } else {
            edgeColor = ImageColorsCounter(color: .black, count: 1)
        }

        if edgeColor.color.isBlackOrWhite && sortedColors.count > 1 {
            for index in 1 ..< sortedColors.count {
                let nextEdgeColor = sortedColors[index]
                if Double(nextEdgeColor.count / edgeColor.count) > 0.3 {
                    if !nextEdgeColor.color.isBlackOrWhite {
                        edgeColor = nextEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        let background = edgeColor.color
        let isBackgroundIsLight = !background.isDarkColor
        sortedColors = imageColors.keys
            .compactMap { pixel in
                let darkerPixel = pixel.newWithSaturation(0.15)
                if darkerPixel.isDarkColor == isBackgroundIsLight {
                    let count = imageColors[pixel]!
                    return ImageColorsCounter(color: darkerPixel, count: count)
                }
                return nil
            }
            .sorted(by: <)

        var primary: Pixel? = nil
        var secondary: Pixel? = nil
        var detail: Pixel? = nil

        for colorsCounter in sortedColors {
            let color = colorsCounter.color
            if primary == nil {
                if color.isContrastingTo(background) {
                    primary = color
                }
            } else if secondary == nil {
                if !color.isContrastingTo(background) || !(primary?.isDistinct(color) ?? false) {
                    continue
                }
                secondary = color
            } else if detail == nil {
                if !color.isContrastingTo(background) || !(secondary?.isDistinct(color) ?? false) || !(primary?.isDistinct(color) ?? false) {
                    continue
                }
                detail = color
            }
        }
        let isBackgroundIsDark = !isBackgroundIsLight
        if primary == nil {
            primary = isBackgroundIsDark ? .white : .black
        }
        if secondary == nil {
            secondary = isBackgroundIsDark ? .white : .black
        }
        if detail == nil {
            detail = isBackgroundIsDark ? .white : .black
        }

        return ImageColors(background: background.imageColor,
                           primary: primary!.imageColor,
                           secondary: secondary!.imageColor,
                           detail: detail!.imageColor)
    }

}
