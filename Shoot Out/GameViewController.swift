//
//  GameViewController.swift
//  Shoot Out
//
//  Created by Joseph Jin on 7/21/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var scene = SKScene()
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var jumpButton: UIButton!
    @IBOutlet var shootButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGesture()
        loadSKS()
    }

    // MARK: Load Spritekit Scene
    func loadSKS() {
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    // MARK: Setting up the UILongPressGestureRecognizers
    func longPressGesture() {
        let leftButtonLPG = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.moveLeft))
        leftButton.addGestureRecognizer(leftButtonLPG)
        
        let rightButtonLPG = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.moveRight))
        rightButton.addGestureRecognizer(leftButtonLPG)
        
        let jumpButtonLPG = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.jump))
        jumpButton.addGestureRecognizer(leftButtonLPG)
        
        let shootButtonLPG = UILongPressGestureRecognizer(target: self, action: #selector(GameScene.shoot))
        shootButton.addGestureRecognizer(leftButtonLPG)
    }
    
    
    
    

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
