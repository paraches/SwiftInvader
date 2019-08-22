//
//  GameScene.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/22.
//  Copyright © 2019 paraches lifestyle lab. All rights reserved.
//

import SpriteKit
import GameplayKit


enum CategoriesBitMask: UInt32 {
    case Wall = 0x01
    case Invader = 0x02
    case Player = 0x04
    case UFO = 0x08
    case InvaderBullet = 0x10
    case PlayerBullet = 0x20
    case StageBorder = 0x40
}

let AncherMargine = CGSize(width: InvaderSize.width / 2.0, height: InvaderSize.height / 2.0)
let ScreenMargineWidth: CGFloat = 11.0    //  (414 - 28 * 14) / 2
let ScreenPlayerRemainAndCreditRow = 0
let ScreenBottomLine = 1
let ScreenCanonRow = 3
let ScreenWallRow: CGFloat = 5
let ScreenUFORow = 27
let ScreenTopLine = 28
let ScreenScoreRow = 29
let ScreenLabelRow = 31

class GameScene: SKScene, SKPhysicsContactDelegate, InvaderGameProtocol {
    let inputController: PPGameInputController
    let invaderGameController = InvaderGameController()
    let stageNum = 0
    
    init(size: CGSize, inputController: PPGameInputController) {
        self.inputController = inputController
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector.zero
        self.physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.black
        
        invaderGameController.delegate = self
        invaderGameController.initGame(self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let (keys, buttons) = inputController.checkController()
        let padKeys = [buttons[.aKey], buttons[.bKey], false, false, false, false, keys[.leftKey], keys[.rightKey]]
        invaderGameController.update(self, keys: padKeys)
    }
    
    func gameOver() {
        guard let viewController = self.view?.window?.contentViewController as? ViewController else {
            return
        }
        let transition = SKTransition.push(with: .right, duration: 0.5)
        viewController.showScene(.demoScene, transition: transition)
    }
    
    //
    //  SKPhysicsContactDelegate
    //
    func didBegin(_ contact: SKPhysicsContact) {
        let (firstBody, secondBody) = sortABBitmaskOrder(contact)
        
        if (firstBody.categoryBitMask & CategoriesBitMask.Invader.rawValue != 0) &&
            (secondBody.categoryBitMask & CategoriesBitMask.PlayerBullet.rawValue != 0) {
            invaderGameController.removeInvader(self, invader: firstBody.node as? Invader)
            invaderGameController.removePlayerBullet(self, bullet: secondBody.node as? PlayerBullet)
        }
        else if (firstBody.categoryBitMask & CategoriesBitMask.UFO.rawValue != 0) &&
            (secondBody.categoryBitMask & CategoriesBitMask.PlayerBullet.rawValue != 0) {
            invaderGameController.removeUFO(self, ufo: firstBody.node as? UFO)
            invaderGameController.removePlayerBullet(self, bullet: secondBody.node as? PlayerBullet)
        }
        else if (firstBody.categoryBitMask & CategoriesBitMask.Player.rawValue != 0) &&
            (secondBody.categoryBitMask & CategoriesBitMask.InvaderBullet.rawValue != 0) {
            invaderGameController.removePlayer(self, player: firstBody.node as? Player)
            invaderGameController.removeInvaderBullet(self, bullet: secondBody.node as? InvaderBullet)
        }
        else if (firstBody.categoryBitMask & CategoriesBitMask.InvaderBullet.rawValue != 0) &&
            (secondBody.categoryBitMask & CategoriesBitMask.StageBorder.rawValue != 0) {
            invaderGameController.removeInvaderBullet(self, bullet: firstBody.node as? InvaderBullet)
        }
        else if (firstBody.categoryBitMask & CategoriesBitMask.Wall.rawValue != 0) && (secondBody.categoryBitMask & CategoriesBitMask.InvaderBullet.rawValue != 0) {
            invaderGameController.removeWall(firstBody.node as? SKSpriteNode)
            invaderGameController.removeInvaderBullet(self, bullet: secondBody.node as? InvaderBullet)
        }
        else if (firstBody.categoryBitMask & CategoriesBitMask.Wall.rawValue != 0) && (secondBody.categoryBitMask & CategoriesBitMask.PlayerBullet.rawValue != 0) {
            invaderGameController.removeWall(firstBody.node as? SKSpriteNode)
            invaderGameController.removePlayerBullet(self, bullet: secondBody.node as? PlayerBullet)
        }
        else if (firstBody.categoryBitMask & CategoriesBitMask.Wall.rawValue != 0) && (secondBody.categoryBitMask & CategoriesBitMask.Invader.rawValue != 0) {
            invaderGameController.removeWall(firstBody.node as? SKSpriteNode)
        }
    }
    
    private func sortABBitmaskOrder(_ contact: SKPhysicsContact) -> (SKPhysicsBody, SKPhysicsBody) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        return (firstBody, secondBody)
    }
}
