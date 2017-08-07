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

    weak var scene: SKScene?
    weak var gameScene: GameScene?
    weak var skView : SKView?
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var jumpButton: UIButton!
    @IBOutlet var shootButton: UIButton!
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGesture()
        loadSKS()
    }
    
    // MARK: Load Spritekit Scene
    func loadSKS() {
        
        self.skView = self.view as! SKView?
        // Load the SKScene from 'GameScene.sks'
        self.scene = SKScene(fileNamed: "GameScene")!
        // Set the scale mode to scale to fit the window
        scene?.size = self.view.bounds.size
        scene?.scaleMode = .aspectFill
        // Present the scene
        skView?.presentScene(scene)
            
            
        skView?.ignoresSiblingOrder = true
            
        skView?.showsFPS = true
        skView?.showsNodeCount = true
        skView?.showsPhysics = false
        
        var convertGameScene : GameScene? { return (view as? SKView)?.scene as? GameScene}
        self.gameScene = convertGameScene!
        //self.gameScene?.viewController = self
    }
    
    // MARK: View Will Disappear
    override func viewWillDisappear(_ animated: Bool) {
        //self.scene = nil
    }
    
    // MARK: Return to Menu
    @IBAction func exitView(_ sender: Any) {
        self.scene = nil
        self.gameScene?.viewController = nil
        self.gameScene = nil
        self.skView = nil
        
        self.skView?.presentScene(nil)
        print("\nAttempting to deallocate \(self.skView?.scene)\n")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // TODO: Continue method call as long as button is held
    func longPressGesture() {
        
        let leftButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.moveLeft))
        leftButton.addGestureRecognizer(leftButtonLPG)
        
        let rightButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.moveRight))
        rightButton.addGestureRecognizer(rightButtonLPG)
        
        let jumpButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.jump))
        jumpButton.addGestureRecognizer(jumpButtonLPG)
        
        let shootButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.shoot))
        shootButton.addGestureRecognizer(shootButtonLPG)
    }
    
    // TODO: Replace method calls eventually
    func moveLeft() {
        self.gameScene?.moveLeft()
    }
    
    func moveRight() {
        self.gameScene?.moveRight()
    }
    
    func jump() {
        self.gameScene?.jump()
    }
    
    func shoot() {
        self.gameScene?.shoot()
    }

    override var shouldAutorotate: Bool {
        return false
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
    
    deinit {
        print("Deinit GameViewController.swift")
    }
    
}
