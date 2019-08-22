//
//  HUDItem.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/15.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

enum HUDItemType: Int {
    case label = 0, value, preference, delay, sprite, wait
}

struct HUDItem {
    var itemType: HUDItemType
    let x: Int
    let y: Int
    var label: String
    var value: Int? = nil
    var form: String? = nil
    
}

extension HUDItem {
    func sprite() -> SKSpriteNode? {
        let text: String
        switch itemType {
        case .label:
            text = label
        case .value:
            text = String(format: form ?? "%d", value ?? 0)
        case .preference:
            let v = UserDefaults.standard.integer(forKey: label)
            text = String(format: form ?? "%d", v)
        case .delay:
            text = label
        case .sprite:
            return characterSprite()
        case .wait:
            return nil
        }
        
        guard let sprite = InvaderFont.sprite(string: text) else {
            return nil
        }
        
        sprite.position = CGPoint(x: ScreenMargineWidth + CGFloat(x) * InvaderFontSize.width,
                                  y: CGFloat(y) * InvaderSize.height)
        sprite.anchorPoint = CGPoint(x: 0, y: 0)
        
        return sprite
    }
    
    private func characterSprite() -> SKSpriteNode? {
        switch label {
        case "ufo":
            let ufo = UFO()
            setSpritePosition(ufo)
            return ufo
        default:
            if let invaderType = InvaderType(rawValue: label) {
                let sprite = Invader(invaderType: invaderType, number: 0)
                setSpritePosition(sprite)
                return sprite
            }
            return nil
        }
    }
    
    //  +4.0 is magic number to fit other strings
    private func setSpritePosition(_ sprite: SKSpriteNode) {
        sprite.position = CGPoint(x: ScreenMargineWidth + CGFloat(x) * InvaderFontSize.width + AncherMargine.width,
                                  y: CGFloat(y) * InvaderSize.height + AncherMargine.height + 4.0)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
}
