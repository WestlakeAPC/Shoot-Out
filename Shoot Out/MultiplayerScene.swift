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
    var mainCharacter = SKSpriteNode()
    var theGround = SKNode()
    var scoreLabel = SKLabelNode()
    var overScreen = SKShapeNode()
    var deathScore = SKLabelNode()
    var bloodParticle = SKEmitterNode(fileNamed: "Blood")
    
    
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
    var playerIsDead = false
    
    // Sound
    var punchSoundEffect : AVAudioPlayer?
    var backgroundMusic : AVAudioPlayer?
    var bulletSoundEffect : AVAudioPlayer?
    
    // Arrays
    var playerBulletArray: NSMutableArray = []
    var enemyBulletArray: NSMutableArray = []
    
    // MARK: Did Move to View
    override func didMove(to view: SKView) {
        print("Multiplayer Game View Size: \(self.frame.size)")
        // Load elements
        loadBarrier()
        loadBackground()
        setUpSound()
        loadMainCharacter(withTexture: jimFacingRightTexture)
    }
        
        
    // MARK: Load Barrier
    func loadBarrier() {
            self.physicsBody = SKPhysicsBody(
                edgeLoopFrom: CGRect(x: 0, y: self.frame.size.height / 4, width: self.frame.size.width, height: self.frame.size.height))
            self.physicsBody?.isDynamic = false
        }
        
    // MARK: Load Background
    func loadBackground() {
            let backGroundImage: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "background.png"))
            
            backGroundImage.anchorPoint = .zero
            backGroundImage.position = .zero
            backGroundImage.zPosition = 0
            backGroundImage.size.width = self.frame.size.width
            backGroundImage.size.height = backGroundImage.size.width * 3/4
            
            
            self.addChild(backGroundImage)
        }
        
    // MARK: Load Main Character
    func loadMainCharacter(withTexture texture: SKTexture) {
            self.mainCharacter = SKSpriteNode(texture: texture)
            
            self.mainCharacter.anchorPoint = CGPoint.zero
            self.mainCharacter.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height / 2)
            self.mainCharacter.zPosition = 3
            
            self.mainCharacter.size.width = self.frame.size.width * 0.05
            self.mainCharacter.size.height = self.mainCharacter.size.width * #imageLiteral(resourceName: "jimCharacR").size.height / #imageLiteral(resourceName: "jimCharacR").size.width
            
            let characterCenter = CGPoint(x: self.mainCharacter.size.width / 2, y: self.mainCharacter.size.height / 2)
            
            self.mainCharacter.physicsBody = SKPhysicsBody(rectangleOf: self.mainCharacter.size,
                                                           center: characterCenter)
            
            self.mainCharacter.physicsBody?.allowsRotation = false
            self.mainCharacter.physicsBody?.isDynamic = true
            
            self.addChild(mainCharacter)
            
            self.bloodParticle?.particleBirthRate = 0
            self.bloodParticle?.position = characterCenter
            self.bloodParticle?.zPosition = -1
            self.mainCharacter.addChild(bloodParticle!)
        }
        
    // MARK: Audio Components
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

    // MARK: Character Movement
    func moveLeft() {
        if playerIsDead {return}
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: -45, dy: 0))
        self.mainCharacter.texture = jimFacingLeftTexture
    }
    
    func moveRight() {
        if playerIsDead {return}
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: 45, dy: 0))
        self.mainCharacter.texture = jimFacingRightTexture
    }
    
    func jump() {
        if playerIsDead {return}
        if self.mainCharacter.position.y < self.frame.size.height * 0.5 {
            self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 95))
        }
    }
    
    
    // MARK: Shoot Function
    func shoot() {
        if playerIsDead {return}
        let bullet = SKBulletsNode(texture: bulletTexture)
        
        if self.mainCharacter.texture == jimFacingLeftTexture {
            bullet.shoot(from:
                self.mainCharacter, to: "left", fromPercentOfWidth: 0.8, fromPercentOfHeight: 0.35, addToArray: playerBulletArray, inScene: self)
            
        } else if self.mainCharacter.texture == jimFacingRightTexture {
            bullet.shoot(from: self.mainCharacter, to: "right", fromPercentOfWidth: 0.8, fromPercentOfHeight: 0.35, addToArray: playerBulletArray, inScene: self)
        }
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
        print("Deinit MultiplayerScene.swift")
    }
}
