//
//  ViewController.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/22.
//  Copyright © 2019 paraches lifestyle lab. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

enum SceneType: Int {
    case demoScene = 0, gameScene
}

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    let inputController = PPGameInputController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showScene(.demoScene)
    }
    
    func showScene(_ sceneType: SceneType, transition: SKTransition = SKTransition.fade(withDuration: 0.01)) {
        if let view = self.skView {
            var scene: SKScene
            
            switch sceneType {
            case .demoScene:
                scene = DemoScene(size: view.bounds.size, inputController: inputController)
            case .gameScene:
                scene = GameScene(size: view.bounds.size, inputController: inputController)
            }
            
            scene.scaleMode = .aspectFill
            scene.anchorPoint = CGPoint(x: 0, y: 0.1)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            view.presentScene(scene, transition: transition)
        }
    }
}

