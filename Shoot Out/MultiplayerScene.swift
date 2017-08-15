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
    var alphaCharacter = SKSpriteNode()
    var betaCharacter = SKSpriteNode()
    var mainCharacter: SKSpriteNode?
    var opposingCharacter: SKSpriteNode?
    
    var theGround = SKNode()
    var scoreLabel = SKLabelNode()
    var overScreen = SKShapeNode()
    var deathScore = SKLabelNode()
    var alphaBloodParticle = SKEmitterNode(fileNamed: "Blood")
    var betaBloodParticle = SKEmitterNode(fileNamed: "Blood")
    
    
    // Textures
    private var jimFacingRightTexture = SKTexture(imageNamed: "jimCharacR.png")
    private var jimFacingLeftTexture = SKTexture(imageNamed: "jimCharacL.png")
    private var enemyCowboyRightTexture = SKTexture(imageNamed: "jimCharac2R.png")
    private var enemyCowboyLeftTexture = SKTexture(imageNamed: "jimCharac2L.png")
    var bulletTexture = SKTexture(imageNamed: "bullet.png")
    
    // Score
    var aliensKilled = 0
    var score = 0
    
    // Death
    var gameIsOver = false
    
    // Sound
    var punchSoundEffect : AVAudioPlayer?
    var backgroundMusic : AVAudioPlayer?
    var bulletSoundEffect : AVAudioPlayer?
    
    // Arrays
    var playerBulletArray: [SKBulletsNode] = []
    var enemyBulletArray: [SKBulletsNode] = []
    
    // MARK: Did Move to View Setup
    override func didMove(to view: SKView) {
        print("Multiplayer Game View Size: \(self.frame.size)")
        
        // Load elements
        loadBarrier()
        setUpSound()
        loadAlphaCharacter(withTexture: jimFacingRightTexture)
        loadBetaCharacter(withTexture: enemyCowboyLeftTexture)
        assignCharacters()
        
        self.backgroundColor = .clear
    }
        
        
    // Load Barrier
    func loadBarrier() {
            self.physicsBody = SKPhysicsBody(
                edgeLoopFrom: CGRect(x: 0, y: self.frame.size.height / 4, width: self.frame.size.width, height: self.frame.size.height))
            self.physicsBody?.isDynamic = false
        }
    
    // Audio Components
    func setUpSound() {
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)
        let music = URL(fileURLWithPath: Bundle.main.path(forResource: "Crazy", ofType: "wav")!)
        
        bulletSoundEffect = try! AVAudioPlayer.init(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "DesertEagleShot", ofType: "mp3")!))
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
    func loadAlphaCharacter(withTexture texture: SKTexture) {
            self.alphaCharacter = SKSpriteNode(texture: texture)
            
            self.alphaCharacter.anchorPoint = CGPoint.zero
            self.alphaCharacter.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height / 2)
            self.alphaCharacter.zPosition = 3
            
            self.alphaCharacter.size.width = self.frame.size.width * 0.05
            self.alphaCharacter.size.height = self.alphaCharacter.size.width * #imageLiteral(resourceName: "jimCharacR").size.height / #imageLiteral(resourceName: "jimCharacR").size.width
            
            let characterCenter = CGPoint(x: self.alphaCharacter.size.width / 2, y: self.alphaCharacter.size.height / 2)
            
            self.alphaCharacter.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.alphaCharacter.size.width * 0.65, height: self.alphaCharacter.size.height), center: characterCenter)
            
            self.alphaCharacter.physicsBody?.allowsRotation = false
            self.alphaCharacter.physicsBody?.isDynamic = true
            
            self.addChild(alphaCharacter)
            
            self.alphaBloodParticle?.particleBirthRate = 0
            self.alphaBloodParticle?.position = characterCenter
            self.alphaBloodParticle?.zPosition = -1
            self.alphaBloodParticle?.name = "Blood"
            self.alphaCharacter.addChild(alphaBloodParticle!)
    }
    
    // Load Beta Character
    func loadBetaCharacter(withTexture texture: SKTexture) {
        self.betaCharacter = SKSpriteNode(texture: texture)
        
        self.betaCharacter.anchorPoint = CGPoint.zero
        self.betaCharacter.position = CGPoint(x: self.frame.size.width * 0.7, y: self.frame.size.height / 2)
        self.betaCharacter.zPosition = 3
        
        self.betaCharacter.size.width = self.frame.size.width * 0.05
        self.betaCharacter.size.height = self.alphaCharacter.size.width * #imageLiteral(resourceName: "jimCharacR").size.height / #imageLiteral(resourceName: "jimCharacR").size.width
        
        let characterCenter = CGPoint(x: self.betaCharacter.size.width / 2, y: self.betaCharacter.size.height / 2)
        
        self.betaCharacter.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.betaCharacter.size.width * 0.65, height: self.betaCharacter.size.height), center: characterCenter)
        
        self.betaCharacter.physicsBody?.allowsRotation = false
        self.betaCharacter.physicsBody?.isDynamic = true
        
        self.addChild(betaCharacter)
        
        self.betaBloodParticle?.particleBirthRate = 0
        self.betaBloodParticle?.position = characterCenter
        self.betaBloodParticle?.zPosition = -1
        self.betaBloodParticle?.name = "Blood"
        self.betaCharacter.addChild(betaBloodParticle!)
    }
    
    // Assign Characters
    func assignCharacters() {
        // Will be worked on later
        self.mainCharacter = self.alphaCharacter
        self.opposingCharacter = self.betaCharacter
        
    }

    // MARK: Character Actions
    func moveLeft() {
        if gameIsOver {return}
        self.mainCharacter?.physicsBody?.applyImpulse(CGVector(dx: -30, dy: 0))
        self.mainCharacter?.texture = jimFacingLeftTexture
    }
    
    func moveRight() {
        if gameIsOver {return}
        self.mainCharacter?.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 0))
        self.mainCharacter?.texture = jimFacingRightTexture
    }
    
    func jump() {
        if gameIsOver {return}
        if (self.mainCharacter?.position.y)! < self.frame.size.height * 0.5 {
            self.mainCharacter?.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 80))
        }
    }
    
    // Shoot Function
    func shoot() {
        if gameIsOver {return}
        let bullet = SKBulletsNode(texture: bulletTexture)
        
        if self.mainCharacter?.texture == jimFacingLeftTexture {
            bullet.shoot(from:
                self.mainCharacter!, to: "left", fromPercentOfWidth: 0.8, fromPercentOfHeight: 0.35, addToArray: playerBulletArray, inScene: self)
            
        } else if self.mainCharacter?.texture == jimFacingRightTexture {
            bullet.shoot(from: self.mainCharacter!, to: "right", fromPercentOfWidth: 0.8, fromPercentOfHeight: 0.35, addToArray: playerBulletArray, inScene: self)
        }
    }
    
    // MARK: Game System Processing
    func gameDidEnd(withDeathOf victim: SKSpriteNode) {
        (victim.childNode(withName: "blood") as! SKEmitterNode).particleBirthRate = 750
        
        self.gameIsOver = true
    }
    
    func gameRestart() {
        (self.alphaCharacter.childNode(withName: "blood") as! SKEmitterNode).particleBirthRate = 0
        (self.betaCharacter.childNode(withName: "blood") as! SKEmitterNode).particleBirthRate = 0
        
        self.mainCharacter?.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.5)
        self.mainCharacter?.texture = jimFacingRightTexture
        
        self.opposingCharacter?.position = CGPoint(x: self.frame.size.width * 0.7, y: self.frame.size.height * 0.5)
        self.opposingCharacter?.texture = enemyCowboyLeftTexture
        
        self.gameIsOver = false
    }
    
    // MARK: When Touches Begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            print("Tapped \(t.location(in: self))")
        }
    }
    
    // MARK: End All Activity
    func endAll() {
        self.removeAllActions()
        self.removeAllChildren()
        self.viewController = nil
    }
    
    deinit {
        print("Deinitialized MultiplayerScene")
    }
}
