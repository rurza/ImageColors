//
//
//  Created by Adam Różyński on 09/08/2021.
//  based on
//  https://github.com/jathu/UIImageColors
//  by Jathu Satkunarajah (@jathu)
//

import Accelerate
import CoreGraphics

public enum ImageColorsError: Error {
    case imageResizeError(vImage_Error)
}

public struct ImageColors {
    public let background: Pixel
    public let primary: Pixel?
    public let secondary: Pixel?
    public let tertiary: Pixel?
}

public enum ImageExtractQuality: CGFloat {
    case lowest = 50
    case low = 100
    case medium = 200
    case high = 300
    case original = 0

    func newSize(from size: CGSize) -> CGSize {
        guard self != .original else { return size }
        if size.width < size.height {
            let ratio = CGFloat(size.height) / CGFloat(size.width)
            return CGSize(width: self.rawValue / ratio, height: self.rawValue)
        } else {
            let ratio = CGFloat(size.width) / CGFloat(size.height)
            return CGSize(width: self.rawValue, height: self.rawValue / ratio)
        }
    }
}



private struct ImageColorsCounter: Comparable, Equatable {
    let pixel: Pixel
    let count: Int

    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.count < rhs.count
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.count == rhs.count && lhs.pixel == rhs.pixel
    }
}

public extension CGImage {

    @available(iOS 15, macOS 12.0, tvOS 15, *)
    func extractColors(withQuality quality: ImageExtractQuality = .low) async throws -> ImageColors {
        return try await withCheckedThrowingContinuation { continuation in
            extractColors(withQuality: quality) { result in
                continuation.resume(with: result)
            }
        }
    }

    func extractColors(withQuality quality: ImageExtractQuality = .low, queue: DispatchQueue = .global(qos: .utility), _ handler: @escaping (Result<ImageColors, Error>) -> Void) {
        queue.async {
            do {
                let colors = try self._extractColors(withQuality: quality)
                DispatchQueue.main.async {
                    handler(.success(colors))
                }
            } catch {
                DispatchQueue.main.async {
                    handler(.failure(error))
                }
            }
        }
    }

    internal func _extractColors(withQuality quality: ImageExtractQuality) throws -> ImageColors {
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
        var finalImageBuffer = try vImage_Buffer(width: Int(newSize.width),
                                                      height: Int(newSize.height),
                                                      bitsPerPixel: expectedImageFormat.bitsPerPixel)
        defer { finalImageBuffer.free() }

        let error = vImageScale_ARGB8888(&destinationImageFormatBuffer,
                                         &finalImageBuffer,
                                         nil,
                                         vImage_Flags(kvImageHighQualityResampling))
        guard error == kvImageNoError else { throw ImageColorsError.imageResizeError(error) }

        // Analyze pixels
        let capacity = finalImageBuffer.rowBytes * Int(finalImageBuffer.height)
        let data = finalImageBuffer.data.bindMemory(to: UInt8.self, capacity: capacity)

        let width = Int(finalImageBuffer.width)
        let height = Int(finalImageBuffer.height)

        var imageColors: Dictionary<Pixel, Int> = [:]

        for x in 0 ..< width {
            for y in 0 ..< height {
                // 4 for as the numer of channels
                let pixel: Int = Int(finalImageBuffer.rowBytes) * y + x * 4
                let alpha = data[pixel]
                if 50 <= alpha { // magic alpha number
                    let red = data[pixel+1]
                    let green = data[pixel+2]
                    let blue = data[pixel+3]
                    imageColors[Pixel(red: red, green: green, blue: blue), default: 0] += 1
                }
            }
        }

        data.deinitialize(count: capacity)
        
        var sortedColors: [ImageColorsCounter] = imageColors.keys
            .map { pixel in
                let count = imageColors[pixel]!
                return ImageColorsCounter(pixel: pixel, count: count)
            }
            .sorted(by: >)
        
        sortedColors = sortedColors.reduce(into: []) { partialResult, colorsCounter in
            var resultsHaveSimilarColor = false
            for (index, result) in partialResult.enumerated() {
                if !result.pixel.isDistinct(colorsCounter.pixel) {
                    resultsHaveSimilarColor = true
                    let copy = ImageColorsCounter(pixel: result.pixel,
                                                  count: result.count + colorsCounter.count)
                    partialResult[index] = copy
                    break
                }
            }
            if !resultsHaveSimilarColor {
                partialResult.append(colorsCounter)
            }
        }
        .sorted(by: >)


        var edgeColor: ImageColorsCounter
        if let first = sortedColors.first {
            edgeColor = first
        } else {
            edgeColor = ImageColorsCounter(pixel: .black, count: 1)
        }

        if edgeColor.pixel.isBlackOrWhite && sortedColors.count > 1 {
            for index in 1 ..< sortedColors.count {
                let nextEdgeColor = sortedColors[index]
                if Double(nextEdgeColor.count) / Double(edgeColor.count) > 0.3 {
                    if !nextEdgeColor.pixel.isBlackOrWhite {
                        edgeColor = nextEdgeColor
                        break
                    }
                } else {
                    break
                }
            }
        }
        let background = edgeColor.pixel

        var primary: Pixel? = nil
        var secondary: Pixel? = nil
        var tertiary: Pixel? = nil

        for colorsCounter in sortedColors {
            let color = colorsCounter.pixel
            if primary == nil {
                if color.isContrastingTo(background) {
                    primary = color
                }
            } else if secondary == nil {
                if !(primary?.isDistinct(color) ?? false) || !color.isDistinct(background) {
                    continue
                }
                secondary = color
            } else if tertiary == nil {
                if  !(secondary?.isDistinct(color) ?? false) || !(primary?.isDistinct(color) ?? false) || !color.isDistinct(background) {
                    continue
                }
                tertiary = color
            }
            if primary != nil && secondary != nil && tertiary != nil { break }
        }

        return ImageColors(background: background,
                           primary: primary,
                           secondary: secondary,
                           tertiary: tertiary)
    }

}
