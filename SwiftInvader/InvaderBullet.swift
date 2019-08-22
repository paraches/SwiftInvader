//
//  InvaderBullet.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/12.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

enum InvaderBulletType: String {
    case asymmetry = "enemy_bullet_0"
    case symmetry = "enemy_bullet_1"
    case ufo = "enemy_bullet_2"
}

let InvaderBulletSpeed: CGVector = CGVector(dx: 0, dy: -500)
let InvaderBulletDuration: Double = 5.0
let InvaderBulletFinishWaitDuration: Double = 0.3

class InvaderBullet: SKSpriteNode {
    let finishTexture: SKTexture
    let type: InvaderBulletType
    var completion: (() -> Void)? = nil
    
    init(type: InvaderBulletType) {
        self.type = type
        let texture = SKTexture(imageNamed: type.rawValue)
        self.finishTexture = SKTexture(imageNamed: "enemy_bullet_finish")
        
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = CategoriesBitMask.InvaderBullet.rawValue
        self.physicsBody?.contactTestBitMask = CategoriesBitMask.Player.rawValue
        self.physicsBody?.collisionBitMask = 0x0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func shoot() {
        let moveBulletAction = SKAction.move(by: InvaderBulletSpeed, duration: InvaderBulletDuration)
        let removeBulletAction = SKAction.removeFromParent()
        run(SKAction.sequence([moveBulletAction, removeBulletAction]), completion: {
            self.completion?()
            self.completion = nil
        })
    }

    func dead(_ scene: SKScene) {
        completion?()
        completion = nil

        removeAllActions()
        texture = finishTexture
        
        run(SKAction.wait(forDuration: InvaderBulletFinishWaitDuration), completion: {
            self.removeFromParent()
        })
    }
}
