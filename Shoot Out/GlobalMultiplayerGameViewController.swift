//
//  GameViewController.swift
//  Shoot Out
//
//  Created by Joseph Jin on 7/21/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import GCHelper

class GlobalMultiplayerGameViewController: UIViewController, GCHelperDelegate {
    
    weak var scene: SKScene?
    weak var gameScene: MultiplayerScene?
    weak var skView : SKView?
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var jumpButton: UIButton!
    @IBOutlet var shootButton: UIButton!
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGesture()
        loadGameScene()
        
        GCHelper.sharedInstance.findMatchWithMinPlayers(2, maxPlayers: 2, viewController: self, delegate: self)
    }
    
    // MARK: Load Game Scene
    func loadGameScene() {
        // Create GameScene object
        scene = MultiplayerScene(fileNamed:"MultiplayerScene")
        
        scene?.scaleMode = .aspectFit
        
        // Present current scene
        skView = (self.view as! SKView)
        skView!.presentScene(scene)
        
        self.gameScene = scene as! MultiplayerScene?
        self.gameScene?.viewController = self
        
        skView!.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
        skView?.showsPhysics = false
        
    }
    
    // Return to Menu
    @IBAction func exitView(_ sender: Any) {
        print("\nAttempting to deallocate \(String(describing: self.skView?.scene))\n")
        self.gameScene?.endAll()
        self.scene = nil
        self.gameScene?.viewController = nil
        self.gameScene = nil
        self.skView = nil
        self.skView?.presentScene(nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Method called when a match has been initiated.
    func matchStarted() {
        
    }
    
    /// Method called when the match has ended.
    func matchEnded() {
        
    }
    
    /// Method called when the device received data about the match from another device in the match.
    func match(_ match: GKMatch, didReceiveData: Data, fromPlayer: String) {
        
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
        print("Deinitialized GlobalMultiplayerGameViewController")
    }
    
}
