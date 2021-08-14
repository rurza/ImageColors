//
//  DropDelegate.swift
//  DropDelegate
//
//  Created by Adam Różyński on 13/08/2021.
//

import Foundation
import SwiftUI
import ImageColors

class ImageDropDelegate: DropDelegate, ObservableObject {

    @Published var imageData: Data?
    @Published var loading = false
    @Published var background: Pixel?
    @Published var primary: Pixel?
    @Published var secondary: Pixel?
    @Published var tertiary: Pixel?
    @Published var error: Error?

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [.fileURL])
    }

    func performDrop(info: DropInfo) -> Bool {
        loading = true
        error = nil
        if let itemProvider = info.itemProviders(for: [.fileURL]).first {
            _ = itemProvider.loadObject(ofClass: URL.self) { url, error in
                DispatchQueue.main.async {
                    if let url = url, let data = try? Data(contentsOf: url), let image = NSImage(data: data) {
                        self.imageData = data
                        image.cgImage(forProposedRect: nil, context: nil, hints: nil)?.extractColors(queue: DispatchQueue.global(qos: .userInitiated), handler: { result in
                            switch result {
                            case .success(let imageColors):
                                self.background = imageColors.background
                                self.primary = imageColors.primary
                                self.secondary = imageColors.secondary
                                self.tertiary = imageColors.tertiary
                            case .failure(let error):
                                self.error = error
                            }
                            self.loading = false
                        })
                    } else {
                        self.error = error
                        self.imageData = nil
                        self.loading = false
                    }
                }
            }
        }
        return true
    }

}
