//
//  DemoScene.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/15.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

enum DemoState: Int {
    case start = 0, animating1, invaders, animating2, idle
}

let demoItems: [HUDItem] = [
    HUDItem(itemType: .label, x: 1, y: ScreenLabelRow, label: HUDScore1Label, value: nil, form: nil),
    HUDItem(itemType: .label, x: 10, y: ScreenLabelRow, label: "HI_SCORE", value: nil, form: nil),
    HUDItem(itemType: .label, x: 19, y: ScreenLabelRow, label: "SCORE<2>", value: nil, form: nil),
    HUDItem(itemType: .value, x: 3, y: ScreenScoreRow, label: HUDScore1Label, value: 0, form: "%05d"),
    HUDItem(itemType: .preference, x: 11, y: ScreenScoreRow, label: HUDHiScoreLabel, value: 0, form: "%05d"),
    HUDItem(itemType: .label, x: 21, y: ScreenScoreRow, label: "00000", value: nil, form: nil),
    HUDItem(itemType: .label, x: 4, y: ScreenCanonRow, label: "*TAIYO CORPORATION*", value: nil, form: nil),
    HUDItem(itemType: .label, x: 19, y: ScreenPlayerRemainAndCreditRow, label: "CREDIT 00", value: nil, form: nil),
    HUDItem(itemType: .delay, x: 12, y: 24, label: "PLAY", value: nil, form: nil),
    HUDItem(itemType: .delay, x: 7, y: 21, label: "SPACE INVADERS", value: nil, form: nil),
    HUDItem(itemType: .wait, x: 0, y: 0, label: "", value: 2, form: nil),
    HUDItem(itemType: .label, x: 4, y: 17, label: "*SCORE ADVANCE TABLE*", value: nil, form: nil),
    HUDItem(itemType: .sprite, x: 8, y: 15, label: "ufo", value: nil, form: nil),
    HUDItem(itemType: .sprite, x: 8, y: 13, label: "squid", value: nil, form: nil),
    HUDItem(itemType: .sprite, x: 8, y: 11, label: "crab", value: nil, form: nil),
    HUDItem(itemType: .sprite, x: 8, y: 9, label: "octopus", value: nil, form: nil),
    HUDItem(itemType: .delay, x: 10, y: 15, label: "=? MYSTERY", value: nil, form: nil),
    HUDItem(itemType: .delay, x: 10, y: 13, label: "=30 POINTS", value: nil, form: nil),
    HUDItem(itemType: .delay, x: 10, y: 11, label: "=20 POINTS", value: nil, form: nil),
    HUDItem(itemType: .delay, x: 10, y: 9, label: "=10 POINTS", value: nil, form: nil),
]

class DemoScene: SKScene {
    let inputController: PPGameInputController
    let staticHUDItemTypes: [HUDItemType] = [.label, .value, .preference, .sprite]
    var itemNumber = 0
    lazy var currentItem: HUDItem = demoItems[itemNumber]
    var demoTimer = 0
    var charCount = 1
    var lastSprite: SKSpriteNode? = nil
    var demoFinished = false
    var waitTimer = 0
    
    init(size: CGSize, inputController: PPGameInputController) {
        self.inputController = inputController
        
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector.zero
        
        backgroundColor = SKColor.black
    }

    override func keyUp(with event: NSEvent) {
        nextScene()
    }
    
    override func mouseUp(with event: NSEvent) {
        nextScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if checkAnyKey() {
            nextScene()
        }
        if demoFinished { return }
        
        if currentItem.itemType == .delay {
            animate(currentItem)
            demoTimer += 1
        }
        else if currentItem.itemType == .wait {
            wait()
        }
        else {
            while staticHUDItemTypes.contains(currentItem.itemType) {
                draw(currentItem)
                if let item = nextItem() {
                    currentItem = item
                }
            }
        }
    }
    
    private func nextScene() {
        guard let viewController = self.view?.window?.contentViewController as? ViewController else {
            return
        }
        let transition = SKTransition.push(with: .left, duration: 0.5)
        viewController.showScene(.gameScene, transition: transition)
    }

    private func checkAnyKey() -> Bool {
        let (_, buttons) = inputController.checkController()
        for item in buttons {
            if item { return true }
        }
        return false
    }
    
    private func nextItem() -> HUDItem? {
        itemNumber += 1
        if itemNumber >= demoItems.count {
            demoFinished = true
            return nil
        }
        return demoItems[itemNumber]
    }
    
    private func wait() {
        if let value = currentItem.value {
            waitTimer += 1
            if waitTimer >= value * 60 {
                waitTimer = 0
                if let item = nextItem() {
                    currentItem = item
                }
            }
        }
    }

    private func draw(_ item: HUDItem) {
        if let sprite = item.sprite() {
            addChild(sprite)
        }
    }

    private func animate(_ item: HUDItem) {
        guard demoTimer % 10 == 0 else { return }
        
        let showText = item.label.substring(range: 0..<charCount)
        if let sprite = InvaderFont.sprite(string: showText) {
            sprite.position = CGPoint(x: ScreenMargineWidth + CGFloat(item.x) * InvaderFontSize.width,
                                      y: CGFloat(item.y) * InvaderSize.height)
            sprite.anchorPoint = CGPoint(x: 0, y: 0)
            addChild(sprite)
            lastSprite?.removeFromParent()
            if charCount < item.label.lengthOfBytes(using: .utf8) {
                lastSprite = sprite
            }
            else {
                lastSprite = nil
                if let item = nextItem() {
                    currentItem = item
                }
                charCount = 1
                return
            }
            charCount += 1
        }
    }
}
