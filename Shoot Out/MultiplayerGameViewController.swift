//
//  MultiplayerGameViewController.swift
//  Shoot Out
//
//  Created by Eli Bradley on 8/17/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class MultiplayerGameViewController: UIViewController {
    
    weak var gameScene: MultiplayerScene?
    
    var characterAssignmentNumber = 0
    var receivedAssignmentNumber = 0
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var jumpButton: UIButton!
    @IBOutlet var shootButton: UIButton!
    @IBOutlet var connectButton: UIButton!
    
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameScene()
        longPressGesture()

        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: connectToPlayers(_:))
    }
    
    // MARK: Load Game Scene
    func loadGameScene() {
        // Create GameScene object
        gameScene = MultiplayerScene(fileNamed: "MultiplayerScene")
        
        gameScene?.scaleMode = .aspectFit
        
        // Present current scene
        skView!.presentScene(gameScene)
        skView?.allowsTransparency = true
        skView?.backgroundColor = .clear
        
        self.gameScene?.viewController = self
        
        skView!.ignoresSiblingOrder = true
        skView?.showsFPS = false
        skView?.showsNodeCount = false
        skView?.showsPhysics = false
        
        connectButton.layer.cornerRadius = 5
        connectButton.alpha = 0.7
    }
    
    @IBAction func connectToPlayers(_ sender: Any) {
        preconditionFailure("Method must be overridden.")
    }
    
    func sendData(_ message: GameEvent) {
        print("Sending data at \(Date())")
        //print("Sending Message: \n\(message)\n\n")
        
        do {
            let messageData = NSKeyedArchiver.archivedData(withRootObject: EncodableGameEvent(message))
            
            try sendData(messageData)
        } catch {
            print("R.I.P. When sending data, you encountered: " + error.localizedDescription)
        }
    }
    
    func sendData(_ data: Data) throws {
        preconditionFailure("Method must be overridden.")
    }
    
    func didReceiveData(_ data: Data) {
        // Decode information received from other player.
        guard let wrappedMessage = NSKeyedUnarchiver.unarchiveObject(with: data) as? EncodableGameEvent else {
            return
        }
        
        let message = wrappedMessage.gameEvent
        print("Received data at \(Date())")
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
            
            case .died:
                gameScene?.victory()
            
            case .restart:
                gameScene?.gameRestart()
            
            default:
                print("Received Other Event Options")
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
    
	// Send Character Death
    func sendCharacterDeath() {
        let message = GameEvent.died

        sendData(message)
    }
    
    // Send Game Restart
    func sendRestart() {
        let message = GameEvent.restart
        
        sendData(message)
    }

    // TODO: Continue method call as long as button is held
    func longPressGesture() {
        
        let leftButtonLPG = UITapGestureRecognizer(target: self, action: #selector(moveLeft))
        leftButton.addGestureRecognizer(leftButtonLPG)
        
        let rightButtonLPG = UITapGestureRecognizer(target: self, action: #selector(moveRight))
        rightButton.addGestureRecognizer(rightButtonLPG)
        
        let jumpButtonLPG = UITapGestureRecognizer(target: self, action: #selector(jump))
        jumpButton.addGestureRecognizer(jumpButtonLPG)
        
        let shootButtonLPG = UITapGestureRecognizer(target: self, action: #selector(shoot))
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
    
    func exitView(_ sender: Any, completion: (() -> Void)?) {
        print("\nAttempting to deallocate \(String(describing: self.skView?.scene))\n")
        self.gameScene?.endAll()
        self.gameScene?.viewController = nil
        self.gameScene = nil
        self.skView = nil
        self.skView?.presentScene(nil)
        
        self.dismiss(animated: true, completion: completion)
    }
}
