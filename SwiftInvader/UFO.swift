//
//  UFO.swift
//  SKSpaceInvader
//
//  Created by paraches on 2019/08/08.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

let UFOMoveDuration: Double = 5.0
let UFOBirthTime = 25 * 60  // every 25 sec
let UFORequiredMinimumInvaderCount = 7
let UFOFinishWaitDuration: Double = 0.15
let UFOScore = [50, 50, 100, 150, 100, 100, 50, 300, 100, 100, 100, 50, 150, 100, 100]
let UFOScoresSprite = [50, 100, 150, 300]
let UFOScoreSpriteDuration = 1.0

class UFO: SKSpriteNode {
    var running = false
    var scoreSprites: [Int: SKSpriteNode]
    let ufoTexture: SKTexture
    let deadTexture = SKTexture(imageNamed: "enemy_dead")
    let ufoFlyingSoundNode: SKAudioNode = SKAudioNode(fileNamed: "ufo_flying.wav")
    let ufoDeadSoundAction = SKAction.playSoundFileNamed("ufo_dead.wav", waitForCompletion: false)

    init() {
        self.ufoTexture = SKTexture(imageNamed: "ufo")
        scoreSprites = UFOScoresSprite.reduce([Int: SKSpriteNode]()) { (dict, score) -> [Int: SKSpriteNode] in
            var dict = dict
            if let sprite = InvaderFont.sprite(string: String(score)) {
                dict[score] = sprite
                return dict
            }
            dict[score] = nil
            return dict
        }

        super.init(texture: ufoTexture, color: SKColor.clear, size: ufoTexture.size())
        
        self.name = "ufo"
        
        self.physicsBody = SKPhysicsBody(texture: ufoTexture, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = false
        self.physicsBody?.categoryBitMask = CategoriesBitMask.UFO.rawValue
        self.physicsBody?.contactTestBitMask = CategoriesBitMask.PlayerBullet.rawValue
        self.physicsBody?.collisionBitMask = 0x0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func go(_ scene: SKScene, shootCount: Int) {
        if parent != nil {
            removeFromParent()
        }
        
        let leftX = AncherMargine.width + ScreenMargineWidth
        let y = CGFloat(ScreenUFORow) * InvaderSize.height
        let leftPoint = CGPoint(x: leftX, y: y)
        let rightX = scene.size.width - AncherMargine.width + ScreenMargineWidth
        let rightPoint = CGPoint(x: rightX, y: y)
        let (startPoint, endPoint) = shootCount % 2 == 0 ? (leftPoint, rightPoint) : (rightPoint, leftPoint)
        position = startPoint
        running = true
        scene.addChild(self)
        addChild(ufoFlyingSoundNode)

        let ufoAction = SKAction.sequence([SKAction.move(to: endPoint, duration: UFOMoveDuration), SKAction.removeFromParent()])
        run(ufoAction, completion: {
            self.ufoFlyingSoundNode.run(SKAction.stop())
            self.ufoFlyingSoundNode.removeFromParent()
            self.running = false
        })
    }
    
    func dead(_ scene: SKScene, shootCount: Int, addScore: @escaping (Int) -> Void) {
        removeAllActions()
        texture = deadTexture
        
        ufoFlyingSoundNode.run(SKAction.stop())
        ufoFlyingSoundNode.removeFromParent()
        ufoFlyingSoundNode.removeAllActions()
        
        run(ufoDeadSoundAction)
        
        run(SKAction.wait(forDuration: UFOFinishWaitDuration), completion: {
            self.removeFromParent()
            self.texture = self.ufoTexture
            self.running = false
            
            let scoreValue: Int = UFOScore[shootCount % UFOScore.count]
            addScore(scoreValue)
            
            if let sprite = self.scoreSprites[scoreValue] {
                sprite.position = self.position
                scene.addChild(sprite)
                sprite.run(SKAction.wait(forDuration: UFOScoreSpriteDuration), completion: {
                    sprite.removeFromParent()
                })
            }
        })
    }
}
