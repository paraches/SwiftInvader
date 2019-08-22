//
//  WallController.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/12.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

let WallColmnList: [CGFloat] = [2, 6, 10, 14]
let WallLeftMargine: CGFloat = -8

class WallController {
    var walls = [Wall]()

    init() {
        initWalls()
    }
    
    private func initWalls() {
        for colmn in WallColmnList {
            let position = CGPoint(x: colmn * InvaderSize.width + WallLeftMargine,
                                   y: ScreenWallRow * InvaderSize.height)
            let wall = Wall(position: position)
            walls.append(wall)
        }
    }

    func placeWalls(_ scene: SKScene) {
        for wall in walls {
            wall.placeWallParts(scene)
        }
    }
    
    func removeWall(_ wall: SKSpriteNode?) {
        guard let wall = wall else { return }
        
        if wall.parent != nil {
            wall.removeFromParent()
        }
    }

    func removeAll() {
        for wall in walls {
            wall.removeAll()
        }
    }
}
