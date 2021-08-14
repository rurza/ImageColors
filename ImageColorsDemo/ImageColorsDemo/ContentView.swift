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
                if let data = dropDelegate.imageData {
                    Image(nsImage: NSImage(data: data)!)
                        .frame(minWidth: 200, minHeight: 300, idealHeight: .infinity)
                }  else {
                    Text("Drop image here")
                        .frame(minWidth: 200, minHeight: 300, idealHeight: .infinity)
                }
            }
            .onDrop(of: [.image, .fileURL], delegate: dropDelegate)
            if dropDelegate.loading {
                ProgressView()
            } else {
                HStack {
                    VStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(dropDelegate.background?.nsColor ?? .clear))
                        Text("Background")
                    }
                    VStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(dropDelegate.primary?.nsColor ?? .clear))
                        Text("Primary")
                    }
                    VStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(dropDelegate.secondary?.nsColor ?? .clear))
                        Text("Secondary")
                    }
                    VStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(dropDelegate.tertiary?.nsColor ?? .clear))
                        Text("Tertiary")
                    }
                }
                .frame(height: 100)
            }
        }
        .padding()

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dropDelegate: ImageDropDelegate())
    }
}
