//
//  ImageColorsDemoApp.swift
//  ImageColorsDemo
//
//  Created by Adam Różyński on 13/08/2021.
//

import SwiftUI

@main
struct ImageColorsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(dropDelegate: ImageDropDelegate())
        }
    }
}
