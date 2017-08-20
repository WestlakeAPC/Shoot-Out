//
//  GameScene.swift
//  Shoot Out
//
//  Created by Joseph Jin on 7/21/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class MultiplayerScene: SKScene {
    // ViewController reference
    var viewController: UIViewController?
    
    // SpriteKit nodes
    var alphaCharacter = SKPlayerNode()
    var betaCharacter = SKPlayerNode()
    var mainCharacter: SKPlayerNode?
    var opposingCharacter: SKPlayerNode?
    
    var theGround = SKNode()
    var scoreLabel = SKLabelNode()
    var overScreen = SKShapeNode()
    var deathStatus = SKLabelNode()
    var alphaBloodParticle = SKEmitterNode(fileNamed: "Blood")
    var betaBloodParticle = SKEmitterNode(fileNamed: "Blood")
    
    
    // Textures
    private var jimFacingRightTexture = SKTexture(imageNamed: "jimCharacR.png")
    private var jimFacingLeftTexture = SKTexture(imageNamed: "jimCharacL.png")
    private var bobFacingRightTexture = SKTexture(imageNamed: "jimCharac2R.png")
    private var bobFacingLeftTexture = SKTexture(imageNamed: "jimCharac2L.png")
    var bulletTexture = SKTexture(imageNamed: "bullet.png")
    
    // Score
    var aliensKilled = 0
    var score = 0
    var shotsFired = 0
    
    // Game State
    var gameIsOver = false
    var gameIsActive = false
    var reloading = false
    
    // Sound
    var punchSoundEffect : AVAudioPlayer?
    var backgroundMusic : AVAudioPlayer?
    var bulletSoundEffect : AVAudioPlayer?
    
    // Arrays
    var playerBulletArray: ArrayReference<SKBulletsNode> = ArrayReference()
    var enemyBulletArray: ArrayReference<SKBulletsNode> = ArrayReference()
    
    // MARK: Did Move to View Setup
    override func didMove(to view: SKView) {
        print("Multiplayer Game View Size: \(self.frame.size)")
        self.backgroundColor = .clear
        
        // Load elements
        loadBarrier()
        setUpSound()
        loadAlphaCharacter()
        loadBetaCharacter()
        setOverScreen()
        
    }
        
        
    // Load Barrier
    func loadBarrier() {
            self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0,
                                                                  y: self.frame.size.height / 4,
                                                                  width: self.frame.size.width,
                                                                  height: self.frame.size.height))
            self.physicsBody?.isDynamic = false
        }
    
    // Audio Components
    func setUpSound() {
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)
        let music = URL(fileURLWithPath: Bundle.main.path(forResource: "Crazy", ofType: "wav")!)
        
        bulletSoundEffect = try! AVAudioPlayer.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "DesertEagleShot",
                                                                                                      ofType: "mp3")!))
        bulletSoundEffect?.prepareToPlay()
        bulletSoundEffect?.numberOfLoops = 0
        
        punchSoundEffect = try! AVAudioPlayer.init(contentsOf: punchSound)
        punchSoundEffect?.prepareToPlay()
        punchSoundEffect?.numberOfLoops = 0
        
        backgroundMusic = try! AVAudioPlayer.init(contentsOf: music)
        backgroundMusic?.prepareToPlay()
        backgroundMusic?.numberOfLoops = -1
        backgroundMusic?.play()
    }
    
    // Load Alpha Character
    func loadAlphaCharacter() {
        self.alphaCharacter.assignTextures(left: jimFacingLeftTexture, right: jimFacingRightTexture)
        self.alphaCharacter.facingDirection = .right
        self.alphaCharacter.updateTexture()
            
        self.alphaCharacter.anchorPoint = CGPoint.zero
        self.alphaCharacter.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height / 2)
        self.alphaCharacter.zPosition = 3
            
        self.alphaCharacter.size.width = self.frame.size.width * 0.05
        self.alphaCharacter.size.height = self.alphaCharacter.size.width * #imageLiteral(resourceName: "jimCharacR").size.height / #imageLiteral(resourceName: "jimCharacR").size.width
            
        let characterCenter = CGPoint(x: self.alphaCharacter.size.width / 2, y: self.alphaCharacter.size.height / 2)
            
        self.alphaCharacter.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.alphaCharacter.size.width * 0.65,
                                                                                height: self.alphaCharacter.size.height),
                                                            center: characterCenter)
            
        self.alphaCharacter.physicsBody?.allowsRotation = false
        self.alphaCharacter.physicsBody?.isDynamic = true
            
        self.addChild(alphaCharacter)
        
        self.alphaBloodParticle?.particleBirthRate = 0
        self.alphaBloodParticle?.position = characterCenter
        self.alphaBloodParticle?.zPosition = -1
        self.alphaBloodParticle?.name = "blood"
        self.alphaCharacter.addChild(alphaBloodParticle!)
    }
    
    // Load Beta Character
    func loadBetaCharacter() {
        self.betaCharacter.assignTextures(left: bobFacingLeftTexture, right: bobFacingRightTexture)
        self.betaCharacter.facingDirection = .left
        self.betaCharacter.updateTexture()
        
        self.betaCharacter.anchorPoint = CGPoint.zero
        self.betaCharacter.position = CGPoint(x: self.frame.size.width * 0.7, y: self.frame.size.height / 2)
        self.betaCharacter.zPosition = 3
        
        self.betaCharacter.size.width = self.frame.size.width * 0.05
        self.betaCharacter.size.height = self.betaCharacter.size.width * #imageLiteral(resourceName: "jimCharacR").size.height / #imageLiteral(resourceName: "jimCharacR").size.width
        
        let characterCenter = CGPoint(x: self.betaCharacter.size.width / 2, y: self.betaCharacter.size.height / 2)
        
        self.betaCharacter.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.betaCharacter.size.width * 0.65,
                                                                           height: self.betaCharacter.size.height),
                                                       center: characterCenter)
        
        self.betaCharacter.physicsBody?.allowsRotation = false
        self.betaCharacter.physicsBody?.isDynamic = true
        
        self.addChild(betaCharacter)
        
        self.betaBloodParticle?.particleBirthRate = 0
        self.betaBloodParticle?.position = characterCenter
        self.betaBloodParticle?.zPosition = -1
        self.betaBloodParticle?.name = "blood"
        self.betaCharacter.addChild(betaBloodParticle!)
    }
    
    // Setup Death Screen
    func setOverScreen() {
        
        self.overScreen = SKShapeNode(rect: CGRect(
            origin: CGPoint(x: self.frame.size.width / 4, y: self.frame.size.height / 4),
            size: CGSize(width: self.frame.size.width / 2, height: self.frame.height / 2)))
        
        self.overScreen.zPosition = 5
        self.overScreen.fillColor = UIColor.white
        self.overScreen.strokeColor = UIColor.black
        self.overScreen.name = "overScreen"
        
        self.addChild(overScreen)
        self.overScreen.run(SKAction.fadeOut(withDuration: 0))
        
        let deathLabel = SKLabelNode()
        deathLabel.text = "Tap to Restart"
        deathLabel.fontName = "kenpixel"
        deathLabel.fontSize = self.frame.size.height / 20
        deathLabel.fontColor = UIColor.black
        deathLabel.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 3)
        deathLabel.zPosition = 15
        
        self.overScreen.addChild(deathLabel)
        
        deathStatus.text = "Points"
        deathStatus.fontName = "kenpixel"
        deathStatus.fontSize = self.frame.size.height / 10
        deathStatus.fontColor = UIColor.black
        deathStatus.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        deathStatus.zPosition = 15
        
        self.overScreen.addChild(deathStatus)
    }
    
    // Assign Characters
    func assignCharacters(localValue localAssignment: Int, remoteValue remoteAssignemt: Int) {
        // Will be worked on later
        if localAssignment > remoteAssignemt {
            self.mainCharacter = self.alphaCharacter
            self.opposingCharacter = self.betaCharacter
            
        } else {
            self.mainCharacter = self.betaCharacter
            self.opposingCharacter = self.alphaCharacter
        }
        self.gameIsActive = true
    }

    // MARK: Character Actions
    func moveLeft() {
        if gameIsOver || !gameIsActive {return}
        self.mainCharacter?.physicsBody?.applyImpulse(CGVector(dx: -30, dy: 0))
        self.mainCharacter?.facingDirection = .left
        self.mainCharacter?.updateTexture()
    }
    
    func moveRight() {
        if gameIsOver || !gameIsActive {return}
        self.mainCharacter?.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 0))
        self.mainCharacter?.facingDirection = .right
        self.mainCharacter?.updateTexture()
    }
    
    func jump() {
        if gameIsOver || !gameIsActive {return}
        if (self.mainCharacter?.position.y)! < self.frame.size.height * 0.5 {
            self.mainCharacter?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 80))
        }
    }
    
    // Shoot Function
    func shoot() {
        if gameIsOver || !gameIsActive || reloading {return}
        
        if shotsFired >= 5 && !reloading {
            reloadGun()
            return
        }
        
        let bullet = SKBulletsNode(texture: bulletTexture)
        
        shotsFired += 1
        
        switch self.mainCharacter!.facingDirection {
        case .left:
            bullet.shoot(from: self.mainCharacter!,
                     to: .left,
                     fromPercentOfWidth: 0.8,
                     fromPercentOfHeight: 0.35,
                     toArray: playerBulletArray,
                     inScene: self)
            
        case .right:
            bullet.shoot(from: self.mainCharacter!,
                     to: .right,
                     fromPercentOfWidth: 0.8,
                     fromPercentOfHeight: 0.35,
                     toArray: playerBulletArray,
                     inScene: self)
            
        }
        
        if let vc = viewController as! LocalMultiplayerGameController? {
            sendPlayerProperties()
            vc.sendShots()
            
        } else {
            // Do casting and method calling for Game Center View Controller
        }
    }
    
    // Reload Gun
    func reloadGun() {
        
        self.reloading = true
        run(SKAction.playSoundFileNamed("reload.mp3", waitForCompletion: false))
        
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {_ in
            self.shotsFired = 0
            self.reloading = false
        })
        
    }
    
    // MARK: Update the Game
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if gameIsOver || !gameIsActive {return}
        sendPlayerProperties()
        checkCollision()
    }
    
    // MARK: Check Bullet to Player Collisions
    func checkCollision() {
        for enemyBullets in enemyBulletArray.array! {
            if (self.mainCharacter?.intersects(enemyBullets))! {
                selfDeath()
            }
        }
    }
    
    // MARK: Sending/Processing Character Data
    func sendPlayerProperties() {
        if gameIsOver || !gameIsActive {return}
        
        if let vc = viewController as! LocalMultiplayerGameController? {
            
            let velocity = ["dx": self.mainCharacter?.physicsBody?.velocity.dx, "dy": self.mainCharacter?.physicsBody?.velocity.dy] as! Dictionary<String, CGFloat>
            let position = ["x": self.mainCharacter?.position.x, "y": self.mainCharacter?.position.y] as! Dictionary<String, CGFloat>
            
            switch self.mainCharacter!.facingDirection {
            case .left:
                vc.sendCharacterState(physicsVelocityOf: velocity,
                                      positionOf: position,
                                      directionOf: "left")
            case .right:
                vc.sendCharacterState(physicsVelocityOf: velocity,
                                      positionOf: position,
                                      directionOf: "right")
            }
            
        } else {
            // Do casting and method calling for Game Center View Controller
        }
    }
    
    // Process Received Character Properties
    func receivedPlayerProperties(velocityDx dx: CGFloat, velocityDx dy: CGFloat, positionX x: CGFloat, positionY y: CGFloat,  directionOf direction: String) {
        if gameIsOver || !gameIsActive {return}
        
        self.opposingCharacter?.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
        self.opposingCharacter?.position = CGPoint(x: x, y: y)
        
        switch direction {
        case "right":
            self.opposingCharacter?.facingDirection = .right
            
        case "left":
            self.opposingCharacter?.facingDirection = .left
            
        default:
            print("")
        }
        self.opposingCharacter?.updateTexture()
        
    }
    
    // Fire Shots From Opposing Character
    func oppositionShots() {
        if gameIsOver || !gameIsActive {return}
        
        let bullet = SKBulletsNode(texture: bulletTexture)
        
        switch self.opposingCharacter!.facingDirection {
        case .left:
            bullet.shoot(from: self.opposingCharacter!,
                         to: .left,
                         fromPercentOfWidth: 0.8,
                         fromPercentOfHeight: 0.35,
                         toArray: enemyBulletArray,
                         inScene: self)
            
        case .right:
            bullet.shoot(from: self.opposingCharacter!,
                         to: .right,
                         fromPercentOfWidth: 0.8,
                         fromPercentOfHeight: 0.35,
                         toArray: enemyBulletArray,
                         inScene: self)
            
        }
    }
    
    // MARK: Game System Processing
    func victory() {
        if gameIsOver || !gameIsActive {return}
        
        self.deathStatus.text = "You Won"
        playerDidDie(withDeathOf: self.opposingCharacter!)
        
        
    }
    
    func selfDeath() {
        if gameIsOver || !gameIsActive {return}
        
        self.deathStatus.text = "You Died"
        playerDidDie(withDeathOf: self.mainCharacter!)
        
        if let vc = viewController as! LocalMultiplayerGameController? {
            vc.sendCharacterDeath()
        } else {
            
        }
        
    }
    
    // When Someone Dies
    func playerDidDie(withDeathOf victim: SKSpriteNode) {
        
        self.gameIsOver = true
        (victim.childNode(withName: "blood") as! SKEmitterNode).particleBirthRate = 800
        
        backgroundMusic?.stop()
        backgroundMusic?.currentTime = 0.0
        
        punchSoundEffect?.play()
        
        self.overScreen.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    func gameRestart() {
        if !gameIsOver {return}
        
        self.gameIsOver = false
        
        // Remove All Bullets
        for b in playerBulletArray.array! {
            b.remove()
        }
        
        // Remove All Enemy Bullets
        for eb in enemyBulletArray.array! {
            eb.remove()
        }
        
        
        (self.mainCharacter?.childNode(withName: "blood") as! SKEmitterNode).particleBirthRate = 0
        (self.opposingCharacter?.childNode(withName: "blood") as! SKEmitterNode).particleBirthRate = 0
        
        self.alphaCharacter.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.betaCharacter.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        self.alphaCharacter.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.5)
        self.alphaCharacter.facingDirection = .right
        self.alphaCharacter.updateTexture()
        
        self.betaCharacter.position = CGPoint(x: self.frame.size.width * 0.7, y: self.frame.size.height * 0.5)
        self.betaCharacter.facingDirection = .left
        self.betaCharacter.updateTexture()
        
        
        if let vc = viewController as! LocalMultiplayerGameController? {
            vc.sendRestart()
        } else {
            
        }
        
            
        // Hide OverScreen
        self.overScreen.run(SKAction.fadeOut(withDuration: 0.5), completion: {
            // Start Music
            self.backgroundMusic?.play()
        })

        
    }
    
    // MARK: When Touches Begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            print("Tapped \(t.location(in: self))")
        
            if !gameIsOver {return}
        
            for i in self.nodes(at: t.location(in: self)) {
                if i.name == "overScreen" {
                    self.gameRestart()
                }
            }
        }
        
    }
    
    // MARK: End All Activity
    func endAll() {
        self.removeAllActions()
        self.removeAllChildren()
        self.viewController = nil
        self.backgroundMusic = nil
    }
    
    deinit {
        print("Deinitialized MultiplayerScene")
    }
}
