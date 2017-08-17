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

class GlobalMultiplayerGameViewController: MultiplayerGameViewController, GCHelperDelegate {
    
    weak var scene: SKScene?
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
    func match(_ match: GKMatch, didReceiveData data: Data, fromPlayer: String) {
        didReceiveData(data)
    }
    
    // MARK: Send data to other player.
    override func sendData(_ data: Data) throws {
        try GCHelper.sharedInstance.match!.sendData(toAllPlayers: data, with: .reliable)
    }
    
    deinit {
        print("Deinitialized GlobalMultiplayerGameViewController")
    }
    
}
