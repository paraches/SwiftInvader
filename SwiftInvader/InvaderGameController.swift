//
//  InvaderController.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/11.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import SpriteKit

protocol InvaderGameProtocol {
    func gameOver()
}

enum GameState: Int {
    case prepareStage = 0, placeInvader, gaming, playerDead, playerRestart, stageClear, gameEnd, idle
}

let InvaderTotalCount = 55
let InvaderTotalColmns = 11
let InvaderBetweenMargine: CGFloat = 8.0
let InvaderStartLeftMargine: CGFloat = InvaderSize.width
let InvaderTypeForRow: [InvaderType] = [.octopus, .octopus, .crab, .crab, .squid]
let InvaderStartRow = [13, 11, 9, 7, 7, 7, 5, 5, 5]

class InvaderGameController {
    var hiScore = UserDefaults.standard.integer(forKey: "hiScore")
    var gameScore = 0
    var gameState: GameState = .idle
    var gameStateTimer = 0
    var stageNum = 0

    var invaders = [Invader]()
    var fireInvaders = [Invader]()
    var currentInvaderNumber = 0
    var needToChangeMoveType = false
    var bullets: [InvaderBullet?] = [nil, nil, nil]

    let player = Player()
    
    var ufoTimer = 0
    var ufo = UFO()
    
    var wallController = WallController()
    
    var hud: HUD? = nil
    
    var delegate: InvaderGameProtocol?
    
    let invaderMoveSound: [SoundName] = [.invader_0, .invader_1, .invader_2, .invader_3]
    var invaderMoveCount = 0

    init() {
        initInvaders()
    }
    
    private func initInvaders() {
        for i in 0..<InvaderTotalCount {
            let row = i / InvaderTotalColmns
            let invaderType = InvaderTypeForRow[row]
            invaders.append(Invader(invaderType: invaderType, number: i))
        }
    }

    func initGame(_ scene: SKScene) {
        hud = HUD(scene: scene)
        initBottomLine(scene)
        gameState = .prepareStage
    }
    
    //  Bottom border line
    private func initBottomLine(_ scene: SKScene) {
        let linePath = CGMutablePath()
        let y = CGFloat(ScreenBottomLine) * InvaderSize.height + 4.0
        linePath.move(to: CGPoint(x: 0, y: y))
        linePath.addLine(to: CGPoint(x: scene.size.width, y: y))
        let shape = SKShapeNode()
        shape.path = linePath
        shape.strokeColor = SKColor.white
        shape.lineWidth = 1.0
        scene.addChild(shape)

        shape.physicsBody = SKPhysicsBody(edgeChainFrom: linePath)
        shape.physicsBody?.isDynamic = false
        shape.physicsBody?.usesPreciseCollisionDetection = false
        shape.physicsBody?.categoryBitMask = CategoriesBitMask.StageBorder.rawValue
        shape.physicsBody?.contactTestBitMask = CategoriesBitMask.InvaderBullet.rawValue
        shape.physicsBody?.collisionBitMask = 0x0
    }

    func prepareStage(_ scene: SKScene) {
        scene.addChild(player)
        player.startStage()
        wallController.placeWalls(scene)
        prepareInvaders(stage: stageNum)
        hud?.updateLabel(itemKey: HUDRemainedPlayerLabel, value: player.canonCount)
        hud?.updateCanon(scene, count: player.canonCount)
    }
    
    private func prepareInvaders(stage: Int) {
        let moveState: MoveState = stage % 2 == 0 ? .right : .left
        
        for invader in invaders {
            invader.moveState = moveState
            invader.currentTextureNum = 0
            let startRow = InvaderStartRow[stage % InvaderStartRow.count]
            let y = CGFloat(startRow + invader.row * 2) * InvaderSize.height
            let x = AncherMargine.width + ScreenMargineWidth + CGFloat(invader.colmn) * (InvaderSize.width + InvaderBetweenMargine) + InvaderStartLeftMargine
            invader.position = CGPoint(x: x, y: y)
        }
        
        currentInvaderNumber = 0
        gameState = .placeInvader
    }

    private func placeInvader(_ scene: SKScene) {
        if invaders.count != InvaderTotalCount { return }
        
        let invader = invaders[currentInvaderNumber]
        invader.alive = true
        if invader.row == 0 {
            fireInvaders.append(invader)
        }
        scene.addChild(invader)
        
        currentInvaderNumber += 1
        if currentInvaderNumber >= invaders.count {
            gameState = .gaming
            currentInvaderNumber = 0
        }
    }

    //
    //  call every 1/60 sec
    //
    func update(_ scene: SKScene, keys: [Bool]) {
        switch gameState {
        case .prepareStage:
            prepareStage(scene)
        case .placeInvader:
            placeInvader(scene)
        case .gaming:
            playSound()
            player.update(scene, keys: keys)
            moveInvader(scene)
            fireBullet(scene)
            ufoTimer(scene)
        case .playerDead:
            break
        case .playerRestart:
            if updateStateTimer(60 * 2) {
                playerRestart(scene)
            }
        case .stageClear:
            player.update(scene, keys: keys)
            if updateStateTimer(60) {
                stageClear()
            }
        case .gameEnd:
            hud?.showGameOver(scene)
            if updateStateTimer(60 * 4) {
                gameOver()
            }
        case .idle:
            break
        }
    }
    
    private func updateStateTimer(_ finishTime: Int) -> Bool {
        gameStateTimer += 1
        if gameStateTimer >= finishTime {
            gameStateTimer = 0
            return true
        }
        return false
    }

    private func playSound() {
        if currentInvaderNumber == 0 {
            SoundManager.sharedInstance.play(invaderMoveSound[invaderMoveCount % invaderMoveSound.count])
            invaderMoveCount += 1
        }
    }
    
    private func stageClear() {
        stageNum += 1
        player.removeFromParent()
        player.removeAllActions()
        ufoTimer = 0
        gameState = .prepareStage
    }

    private func gameOver() {
        if gameScore > hiScore {
            UserDefaults.standard.set(gameScore, forKey: "hiScore")
        }
        delegate?.gameOver()
    }
    
    private func addScore(_ scene: SKScene, score: Int) {
        gameScore += score
        hud?.updateLabel(itemKey: HUDScore1Label, value: gameScore)
    }
    
    private func moveInvader(_ scene: SKScene) {
        if let invader = nextInvader() {
            invader.update({ newPosition in
                if (newPosition.x < ScreenMargineWidth + InvaderSize.width / 2) ||
                    (newPosition.x > scene.size.width - ScreenMargineWidth - InvaderSize.width / 2) {
                    needToChangeMoveType = true
                }
                if (newPosition.y <= InvaderSize.height * CGFloat(ScreenCanonRow)) {
                    player.canonCount = 0
                    removePlayer(scene, player: player)
                }
            })
        }
    }
    
    private func nextInvader() -> Invader? {
        while invaders.count != 0 {
            if currentInvaderNumber == 0 && needToChangeMoveType {
                invaders.forEach({ $0.nextState() })
                needToChangeMoveType = false
            }
            else if currentInvaderNumber == 0 {
                invaders.forEach({ $0.checkMoveState() })
            }
            let invader = invaders[currentInvaderNumber]
            currentInvaderNumber += 1
            if currentInvaderNumber >= invaders.count {
                currentInvaderNumber = 0
            }
            if invader.alive { return invader }
        }
        
        return nil
    }
    
    private func fireBullet(_ scene: SKScene) {
        if bullets[0] == nil && arc4random_uniform(InvaderFireRate) == 1 {
            if let invader = findNearest() {
                if let invaderBullet = invader.fireBullet(scene, type: .asymmetry, completion: {
                    self.bullets[0] = nil
                    invader.fired = false
                }) {
                    bullets[0] = invaderBullet
                }
            }
        }
        else if bullets[1] == nil && fireInvaders.count > 1 && arc4random_uniform(InvaderFireRate) == 1 {
            if let invader = randomInvader() {
                if let invaderBullet = invader.fireBullet(scene, type: .symmetry, completion: {
                    self.bullets[1] = nil
                    invader.fired = false
                }) {
                    bullets[1] = invaderBullet
                }
            }
        }
        else if (bullets[2] == nil) && (fireInvaders.count > 2) && (arc4random_uniform(InvaderFireRate) == 1) && !ufo.running {
            if let invader = randomInvader() {
                if let invaderBullet = invader.fireBullet(scene, type: .ufo, completion: {
                    self.bullets[2] = nil
                    invader.fired = false
                }) {
                    bullets[2] = invaderBullet
                }
            }
        }
    }
    
    private func findNearest() -> Invader? {
        if fireInvaders.count == 0 { return nil }
        
        let x = player.position.x
        let nearestInvader = fireInvaders.min(by: { (a, b) -> Bool in
            return abs(a.position.x - x) < abs(b.position.x - x)
        })
        
        if let nearestInvader = nearestInvader {
            return nearestInvader.fired ? nil : nearestInvader
        }
        return nil
    }

    private func randomInvader() -> Invader? {
        if fireInvaders.count == 0 { return nil }
        
        let index = Int(arc4random_uniform(UInt32(fireInvaders.count)))
        let invader = fireInvaders[index]
        return invader.fired ? nil : invader
    }
    
    private func alivedInvaderCount() -> Int {
        return invaders.reduce(0) { $0 + ($1.alive ? 1 : 0) }
    }
    
    func removeInvaderBullet(_ scene: SKScene, bullet: InvaderBullet?) {
        guard let bullet = bullet else { return }
        
        bullet.dead(scene)
    }
    
    func removeInvader(_ scene: SKScene, invader: Invader?) {
        guard let invader = invader, invader.alive else { return }
        
        invader.alive = false
        invader.dead(scene)
        
        addScore(scene, score: invader.score)
        
        updateFireInvader(invader)
        
        if finishStage() {
            gameState = .stageClear
        }
    }

    private func finishStage() -> Bool {
        for invader in invaders {
            if invader.alive { return false }
        }
        return true
    }

    private func updateFireInvader(_ removeInvader: Invader) {
        if let _ = fireInvaders.remove(object: removeInvader) {
            for invader in invaders {
                if invader.colmn == removeInvader.colmn && invader.alive {
                    fireInvaders.append(invader)
                    break
                }
            }
        }
        else {
            print("invader(\(removeInvader.number)) is not in FireInvader")
        }
    }

    private func ufoTimer(_ scene: SKScene) {
        ufoTimer += 1
        if ufoTimer % UFOBirthTime == 0 && alivedInvaderCount() > UFORequiredMinimumInvaderCount {
            ufo.go(scene, shootCount: player.shootCount)
        }
    }
    
    func removeUFO(_ scene: SKScene, ufo: UFO?) {
        guard let ufo = ufo else { return }
        
        ufo.dead(scene, shootCount: player.shootCount, addScore: { ufoScore in
            self.addScore(scene, score: ufoScore)
        })
    }

    func removeWall(_ wall: SKSpriteNode?) {
        guard let wall = wall else { return }
        
        wallController.removeWall(wall)
    }
    
    private func playerRestart(_ scene: SKScene) {
        if player.parent == nil {
            scene.addChild(player)
        }
        hud?.updateLabel(itemKey: HUDRemainedPlayerLabel, value: player.canonCount)
        hud?.updateCanon(scene, count: player.canonCount)
        
        gameState = .gaming
    }
    
    func removePlayer(_ scene: SKScene, player: Player?) {
        guard let player = player else { return }
        
        if gameState != .playerDead {
            gameState = .playerDead
            player.dead(scene, completion: {
                self.gameState = player.gameEnd ? .gameEnd : .playerRestart
            })
        }
    }

    func removePlayerBullet(_ scene: SKScene, bullet: PlayerBullet?) {
        player.removeBullet(scene, bullet)
    }
}
