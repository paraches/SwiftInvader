//
//  PlayerBullet.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/12.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

let PlayerBulletDuration = 1.0
let PlayerBulletFinishWaitDuration = 0.3

class PlayerBullet: SKSpriteNode {
    let bulletTexture = SKTexture(imageNamed: "player_bullet")
    let finishTexture = SKTexture(imageNamed: "player_bullet_finish")
    
    init(imageName: String) {
        super.init(texture: bulletTexture, color: SKColor.clear, size: bulletTexture.size())
        
        self.physicsBody = SKPhysicsBody(texture: bulletTexture, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = CategoriesBitMask.PlayerBullet.rawValue
        self.physicsBody?.contactTestBitMask = CategoriesBitMask.Invader.rawValue | CategoriesBitMask.UFO.rawValue
        self.physicsBody?.collisionBitMask = 0x0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        removeFromParent()
        removeAllActions()
        size = bulletTexture.size()
        texture = bulletTexture
    }
    
    func shoot(to toPoint: CGPoint, completion: @escaping () -> Void) {
        run(SKAction.move(to: toPoint, duration: PlayerBulletDuration), completion: {
            self.finish(completion: completion)
        })
    }
    
    private func finish(completion: @escaping () -> Void) {
        size = finishTexture.size()
        texture = finishTexture
        run(SKAction.wait(forDuration: PlayerBulletFinishWaitDuration), completion: {
            self.reset()
            completion()
        })
    }
}
