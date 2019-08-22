//
//  Invader.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/11.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

enum InvaderType: String {
    case octopus = "octopus"
    case crab = "crab"
    case squid = "squid"
}

enum MoveState: Int {
    case right = 0
    case downAtRight = 1
    case left = 2
    case downAtLeft = 3
}

extension MoveState {
    func nextState() -> MoveState {
        let value = self.rawValue + 1
        return MoveState(rawValue: value) ?? .right
    }
}

let InvaderScore: [InvaderType: Int] = [.octopus: 10, .crab: 20, .squid: 30]
let InvaderSize = CGSize(width: 24, height: 16)
let InvaderFireRate: UInt32 = 30
let InvaderFinishWaitDuration: Double = 0.15

let moveVectors: [MoveState: CGVector] = [
    .right: CGVector(dx: 4, dy: 0),
    .downAtRight: CGVector(dx: 0, dy: -InvaderSize.height),
    .left: CGVector(dx: -4, dy: 0),
    .downAtLeft: CGVector(dx: 0, dy: -InvaderSize.height)
]

class Invader: SKSpriteNode {
    public static func ==(lhs: Invader, rhs: Invader) -> Bool {
        return lhs.number == rhs.number
    }

    let invaderType: InvaderType
    var number = 0
    var textures = [SKTexture]()
    var currentTextureNum = 0
    let deadTexture = SKTexture(imageNamed: "enemy_dead")
    var moveState: MoveState = .right
    var fired = false
    var alive = false
    let invaderDeadSoundAction = SKAction.playSoundFileNamed("invaderDead.wav", waitForCompletion: false)
    
    var score: Int {
        get {
            return InvaderScore[invaderType] ?? 0
        }
    }
    
    var colmn: Int {
        get {
            return number % InvaderTotalColmns
        }
    }
    
    var row: Int {
        get {
            return number / InvaderTotalColmns
        }
    }

    init(invaderType: InvaderType, number: Int) {
        self.number = number
        self.invaderType = invaderType
        for i in 0...1 {
            let texture = SKTexture(imageNamed: "\(invaderType.rawValue)_\(i)")
            textures.append(texture)
        }
        super.init(texture: textures[0], color: SKColor.clear, size: textures[0].size())
        
        self.physicsBody = SKPhysicsBody(texture: textures[0], size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = false
        self.physicsBody?.categoryBitMask = CategoriesBitMask.Invader.rawValue
        self.physicsBody?.contactTestBitMask = CategoriesBitMask.PlayerBullet.rawValue | CategoriesBitMask.Player.rawValue
        self.physicsBody?.collisionBitMask = 0x0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func changeTexture() {
        currentTextureNum += 1
        self.texture = textures[currentTextureNum % textures.count]
    }

    func update(_ newPositionCheck: (CGPoint) -> Void) {
        guard let moveVector = moveVectors[moveState] else { return }

        let newPosition = CGPoint(x: position.x + moveVector.dx, y: position.y + moveVector.dy)
        position = newPosition

        changeTexture()

        newPositionCheck(position)
    }
    
    func nextState() {
        moveState = moveState.nextState()
    }
    
    func checkMoveState() {
        if moveState == .downAtRight || moveState == .downAtLeft {
            moveState = moveState.nextState()
        }
    }
    
    func fireBullet(_ scene: SKScene, type: InvaderBulletType, completion: @escaping () -> Void) -> InvaderBullet? {
        let bullet = InvaderBullet(type: type)
        bullet.position.x = position.x
        bullet.position.y = position.y - InvaderSize.height * 2.0 - 1.0 // -1.0 is for Nagoya-uchi
        bullet.completion = completion
        scene.addChild(bullet)
        fired = true
        
        bullet.shoot()

        return bullet
    }
    
    func dead(_ scene: SKScene) {
        texture = deadTexture
        run(SKAction.group([invaderDeadSoundAction, SKAction.wait(forDuration: InvaderFinishWaitDuration)]), completion: {
            if self.parent != nil {
                self.removeFromParent()
                self.texture = self.textures[0]
            }
        })
    }
}
