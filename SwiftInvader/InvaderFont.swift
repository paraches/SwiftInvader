//
//  InvaderFont.swift
//  SKSpaceInvader
//
//  Created by paraches on 2019/08/09.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

fileprivate let fontWidth: CGFloat = 10
fileprivate let fontHeight: CGFloat = 22
fileprivate let fontMargine: CGFloat = 4
let InvaderFontSize = CGSize(width: fontWidth + fontMargine, height: fontHeight)

struct InvaderFont {
    private init() {}
    private static var fontImage = CGImage.image(from: NSImage(named: "invader_font"))
    private static let scale = NSScreen.main?.backingScaleFactor ?? 1.0
    
    static func sprite(string: String) -> SKSpriteNode? {
        guard let image = image(string: string) else { return nil }
        
        let texture = SKTexture(cgImage: image)
        let sprite = SKSpriteNode(texture: texture, color: SKColor.clear, size: texture.size())
        return sprite
    }
    
    static func image(string: String) -> CGImage? {
        if string.lengthOfBytes(using: .utf8) == 0 {
            return nil
        }

        let chCode = string.uppercased().unicodeScalars.map { Int($0.value - 0x20) }

        let cgImageSize = CGSize(width: ((fontWidth + fontMargine) * CGFloat(chCode.count) - fontMargine) / scale,
                                 height: fontHeight / scale)

        let image = NSImage(size: cgImageSize)
        image.lockFocus()
        drawChCode(chCode)
        image.unlockFocus()

        return image.cgImage
    }
    
    private static func drawChCode(_ codes: [Int]) {
        if let ctx = NSGraphicsContext.current?.cgContext {
            for (i, code) in codes.enumerated() {
                if let chImage = charCGImage(code) {
                    let chRect = CGRect(x: CGFloat(i) * (fontWidth + fontMargine) / scale, y: 0.0,
                                        width: fontWidth / scale, height: fontHeight / scale)
                    ctx.draw(chImage, in: chRect)
                }
            }
        }
    }

    private static func charCGImage(_ ch: Int) -> CGImage? {
        let x = CGFloat(ch) * fontWidth
        let rect = CGRect(x: x, y: 0, width: fontWidth, height: fontHeight)
        return fontImage?.cropping(to: rect)
    }
}
