//
//  ContentView.swift
//  ImageColorsDemo
//
//  Created by Adam Różyński on 13/08/2021.
//

import SwiftUI
import ImageColors

enum Quality: String, Identifiable, CaseIterable {
    case original
    case lowest
    case low
    case medium
    case high

    var id: String {
        self.rawValue
    }
}

struct ContentView: View {

    @ObservedObject var dropDelegate: ImageDropDelegate

    var body: some View {
        HStack {
            GroupBox {
                Group {
                    if let data = dropDelegate.imageData {
                        Image(nsImage: NSImage(data: data)!)
                            .resizable()
                            .scaledToFit()
                    }  else {
                        Text("Drop image here")
                    }
                }
                .padding()
                .frame(minWidth: 200, minHeight: 300, idealHeight: .infinity)

            }
            .onDrop(of: [.image, .fileURL], delegate: dropDelegate)
            Group {
                VStack {
                    Picker("Quality", selection: $dropDelegate.quality) {
                        Text(Quality.original.rawValue).tag(ImageExtractQuality.original)
                        Text(Quality.lowest.rawValue).tag(ImageExtractQuality.lowest)
                        Text(Quality.low.rawValue).tag(ImageExtractQuality.low)
                        Text(Quality.medium.rawValue).tag(ImageExtractQuality.medium)
                        Text(Quality.high.rawValue).tag(ImageExtractQuality.high)
                    }
                    Spacer()
                    if dropDelegate.loading {
                        ProgressView()
                            .scaleEffect(0.5)
                    } else if dropDelegate.background != nil {
                        HStack(alignment: .top) {
                            ColorView(color: dropDelegate.background, title: "Background")
                            ColorView(color: dropDelegate.primary, title: "Primary")
                            ColorView(color: dropDelegate.secondary, title: "Secondary")
                            ColorView(color: dropDelegate.tertiary, title: "Tertiary")
                        }
                    }
                    Spacer()
                }
            }
            .frame(width: 300)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dropDelegate: ImageDropDelegate())
    }
}

struct ColorView: View {

    let color: Pixel?
    let title: String

    var body: some View {
        VStack {
            Circle()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(color?.nsColor ?? .clear))
            Text(title)
        }
    }
}
