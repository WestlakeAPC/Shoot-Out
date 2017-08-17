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
    
    var characterAssignmentNumber: Int = 0
    var receivedAssignmentNumber: Int = 0
    
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
        // Decode information received from other player.
        guard let message = NSKeyedUnarchiver.unarchiveObject(with: data) as? GameEvent else {
            return
        }
        
        // Act on it.
        switch message {
            case .characterAssignment(let randomNumber):
                self.receivedAssignmentNumber = randomNumber
                gameScene?.assignCharacters(localValue: self.characterAssignmentNumber, remoteValue: self.receivedAssignmentNumber)
            
            case .propertyUpdate(let properties):
                let velocity = properties.ourCharacterPhysics
                let position = properties.ourCharacterPosition
                let direction = properties.ourCharacterDirection
                
                gameScene?.receivedPlayerProperties(velocity: velocity, position: position, direction: direction)
            
            case .shot:
                gameScene?.oppositionShots()
            
            default:
                print("Received Other Event Options")
        }
    }
    
    // MARK: Send data to other player.
    func sendData(_ message: GameEvent) {
        print("Sending Message: \n\(message)\n\n")
        
        do {
            let messageData = NSKeyedArchiver.archivedData(withRootObject: message)
            
            try GCHelper.sharedInstance.match!.sendData(toAllPlayers: messageData, with: .reliable)
        } catch {
            print("R.I.P. When sending data, you encountered: " + error.localizedDescription)
        }
    }
    
    // Character Assignment
    func sendAssignmentNumber() {
        // Send Random Number Message
        self.characterAssignmentNumber = Int(arc4random_uniform(UInt32(99999999)))
        
        sendData(GameEvent.characterAssignment(randomNumber: self.characterAssignmentNumber))
    }
    
    // Sending Character State
    func sendCharacterState(withPhysicsBody physics: SKPhysicsBody,
                            at position: CGPoint,
                            towards direction: Direction) {
        
        let properties = Properties(ourCharacterPhysics: physics.velocity,
                                    ourCharacterPosition: position,
                                    ourCharacterDirection: direction,
                                    playerBulletArray: [],
                                    enemyBulletArray: [])
        let message = GameEvent.propertyUpdate(properties)
        
        sendData(message)
    }
    
    // Send Shoot Action
    func sendShots() {
        let message = GameEvent.shot
        
        sendData(message)
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
    @objc func moveLeft() {
        self.gameScene?.moveLeft()
    }
    
    @objc func moveRight() {
        self.gameScene?.moveRight()
    }
    
    @objc func jump() {
        self.gameScene?.jump()
    }
    
    @objc func shoot() {
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
