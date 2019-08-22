//
//  HUD.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/14.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit


fileprivate let labelItems: [HUDItem] = [
    HUDItem(itemType: .label, x: 1, y: ScreenLabelRow, label: HUDScore1Label, value: nil, form: nil),
    HUDItem(itemType: .label, x: 10, y: ScreenLabelRow, label: "HI_SCORE", value: nil, form: nil),
    HUDItem(itemType: .preference, x: 11, y: ScreenScoreRow, label: HUDHiScoreLabel, value: 0, form: "%05d"),
    HUDItem(itemType: .label, x: 19, y: ScreenPlayerRemainAndCreditRow, label: "CREDIT 00", value: nil, form: nil),
    HUDItem(itemType: .value, x: 2, y: ScreenScoreRow, label: HUDScore1Label, value: 0, form: "%05d"),
    HUDItem(itemType: .value, x: 1, y: ScreenPlayerRemainAndCreditRow, label: HUDRemainedPlayerLabel, value: 3, form: "%d")
]
fileprivate let gameOverLabelItem = HUDItem(itemType: .label, x: 10, y: 24, label: "GAME OVER", value: nil, form: nil)

let HUDScore1Label = "SCORE<1>"
let HUDRemainedPlayerLabel = "RemainedPlayer"
let HUDHiScoreLabel = "hiScore"

class HUD {
    var valuedHUDItems: [String: (SKSpriteNode, String)] = [String: (SKSpriteNode, String)]()
    var gameOverLabelSprite: SKSpriteNode? = nil
    var remainedPlayerCanonSprites = [SKSpriteNode]()
    
    init(scene: SKScene) {
        initLabels(scene)
    }

    func showGameOver(_ scene: SKScene) {
        if gameOverLabelSprite != nil { return }
        
        if let sprite = gameOverLabelItem.sprite() {
            scene.addChild(sprite)
            gameOverLabelSprite = sprite
        }
    }
    
    func updateCanon(_ scene: SKScene, count: Int) {
        for sprite in remainedPlayerCanonSprites {
            sprite.removeFromParent()
        }
        
        if count < 2 { return }
        
        for i in 0..<count-1 {
            let texture = SKTexture(imageNamed: "player")
            let sprite = SKSpriteNode(texture: texture, color: NSColor.clear, size: texture.size())
            let position = CGPoint(x: ScreenMargineWidth + 40 + (InvaderSize.width + 8) * CGFloat(i),
                                   y: 0)
            sprite.position = position
            sprite.anchorPoint = CGPoint(x: 0, y: 0)
            scene.addChild(sprite)
            remainedPlayerCanonSprites.append(sprite)
        }
    }
    
    func updateLabel(itemKey: String, value: Int) {
        if let (sprite, form) = valuedHUDItems[itemKey] {
            let newValueString = String(format: form, value)
            if let cgImage = InvaderFont.image(string: newValueString) {
                let texture = SKTexture(cgImage: cgImage)
                sprite.texture = texture
            }
        }
    }
    
    private func initLabels(_ scene: SKScene) {
        for item in labelItems {
            switch item.itemType {
            case .label, .preference:
                draw(label: item, scene: scene)
            case .value:
                draw(value: item, scene: scene)
            default:
                break
            }
        }
    }
    
    private func draw(label: HUDItem, scene: SKScene) {
        if let sprite = label.sprite() {
            scene.addChild(sprite)
        }
    }
    
    private func draw(value: HUDItem, scene: SKScene) {
        if let sprite = value.sprite(), let form = value.form {
            scene.addChild(sprite)
            valuedHUDItems[value.label] = (sprite, form)
        }
    }
    
}
