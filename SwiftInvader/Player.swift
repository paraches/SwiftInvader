//
//  Player.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/12.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

let PlayerStartCanonCount = 3
let PlayerStartPosition = CGPoint(x: ScreenMargineWidth + 30.0 + AncherMargine.width,
                                  y: CGFloat(ScreenCanonRow) * InvaderSize.height)
let PlayerSpeed: CGFloat = 2.0

class Player: SKSpriteNode {
    let bullet = PlayerBullet(imageName: "player_bullet")
    var canFire = true
    var shootCount = 0
    var canonCount = PlayerStartCanonCount
    let deadSprite = SKSpriteNode(imageNamed: "player_dead")
    let shootSoundAction = SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)
    let explosionSoundAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    var gameEnd: Bool {
        return canonCount <= 0 ? true : false
    }
    
    init() {
        let texture = SKTexture(imageNamed: "player")
        super.init(texture: texture, color: NSColor.clear, size: texture.size())
        self.position = PlayerStartPosition
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = false
        self.physicsBody?.categoryBitMask = CategoriesBitMask.Player.rawValue
        self.physicsBody?.contactTestBitMask = CategoriesBitMask.InvaderBullet.rawValue | CategoriesBitMask.Invader.rawValue
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.collisionBitMask = 0x0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startStage() {
        canFire = true
        shootCount = 0
        position = PlayerStartPosition
    }
    
    func dead(_ scene: SKScene, completion: @escaping () -> Void) {
        canonCount -= 1
        
        scene.run(explosionSoundAction)
        
        deadSprite.position = position
        removeFromParent()
        removeAllActions()
        scene.addChild(deadSprite)
        position = PlayerStartPosition
        deadSprite.run(SKAction.wait(forDuration: 1.0), completion: {
            self.deadSprite.removeFromParent()
            completion()
        })
    }
    
    func fireBullet(_ scene: SKScene) {
        if !canFire { return }
        
        canFire = false
        shootCount += 1
        run(shootSoundAction)

        bullet.position.x = position.x
        bullet.position.y = position.y + InvaderSize.height
        scene.addChild(bullet)
        
        let toPoint = CGPoint(x: position.x, y: CGFloat(ScreenTopLine) * InvaderSize.height)
        bullet.shoot(to: toPoint, completion: {
            self.canFire = true
        })
    }
    
    func removeBullet(_ scene: SKScene, _ bullet: PlayerBullet?) {
        guard let bullet = bullet else { return }
        
        bullet.reset()
        canFire = true
    }
    
    var aKeyPushed = false
    func update(_ scene: SKScene, keys: [Bool]) {
        for (index, key) in keys.enumerated() {
            if key {
                switch index {
                case .leftKey:
                    let newX = position.x - PlayerSpeed
                    if newX < ScreenMargineWidth + size.width / 2.0 { return }
                    position = CGPoint(x: newX, y: position.y)
                case .rightKey:
                    let newX = position.x + PlayerSpeed
                    if newX > scene.size.width - ScreenMargineWidth - (size.width / 2.0) { return }
                    position = CGPoint(x: newX, y: position.y)
                case .aKey:
                    aKeyPushed = true
                default:
                    break
                }
            }
        }
        if aKeyPushed && (keys[.aKey] == false) {
            aKeyPushed = false
            fireBullet(scene)
        }
    }
}
