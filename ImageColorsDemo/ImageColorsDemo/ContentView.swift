//
//  ContentView.swift
//  ImageColorsDemo
//
//  Created by Adam Różyński on 13/08/2021.
//

import SwiftUI
import ImageColors

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
                } else {
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
