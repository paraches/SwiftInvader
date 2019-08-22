//
//  Wall.swift
//  SKSpaceInvader
//
//  Created by paraches on 2019/08/08.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

let WallPositionX = [0, 10, 16, 22, 28, 34]
let WallPartsHeight = 8
let WallPartsRows = 4
let WallPartsColmns = 6
let WallPartsImageTable = [2, 6, 8, 8, 7, 2,
                           2, 5, 5, 5, 5, 2,
                           1, 5, 5, 5, 5, 4,
                           0, 5, 5, 5, 5, 3]
class Wall {
    var parts = [SKSpriteNode?]()
    
    init(position: CGPoint) {
        initWallParts(position: position)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initWallParts(position: CGPoint) {
        for (index, partsNum) in WallPartsImageTable.enumerated() {
            if partsNum == 8 {
                parts.append(nil)
                continue
            }
            let texture = SKTexture(imageNamed: "wall_\(partsNum)")
            let sprite = SKSpriteNode(texture: texture, color: SKColor.clear, size: texture.size())
            let x = position.x + CGFloat(WallPositionX[index % WallPositionX.count])
            let y = position.y + CGFloat(WallPartsHeight * Int(index / WallPartsColmns))
            sprite.position = CGPoint(x: x, y: y)
            sprite.anchorPoint = CGPoint(x: 0, y: 0)
            
            sprite.name = "wall"
            
            sprite.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
            sprite.physicsBody?.isDynamic = true
            sprite.physicsBody?.usesPreciseCollisionDetection = false
            sprite.physicsBody?.categoryBitMask = CategoriesBitMask.Wall.rawValue
            sprite.physicsBody?.contactTestBitMask = CategoriesBitMask.PlayerBullet.rawValue | CategoriesBitMask.InvaderBullet.rawValue | CategoriesBitMask.Invader.rawValue
            sprite.physicsBody?.collisionBitMask = 0x0
            
            parts.append(sprite)
        }
    }
    
    func placeWallParts(_ scene: SKScene) {
        for item in parts {
            if let item = item, item.parent == nil {
                scene.addChild(item)
            }
        }
    }
    
    func removeAll() {
        for item in parts {
            if item?.parent != nil {
                item?.removeFromParent()
            }
        }
    }
}
