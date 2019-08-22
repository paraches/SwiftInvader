//
//  NSImage+translation.swift
//  SixteenGame
//
//  Created by paraches on 2019/07/19.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
    public var cgImage: CGImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }
}

extension CGImage {
    public var nsImage: NSImage? {
        let size = CGSize(width: self.width, height: self.height)
        return NSImage(cgImage: self, size: size)
    }
    
    static func image(from nsImage: NSImage?) -> CGImage? {
        guard let imageData = nsImage?.tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
    }
}
