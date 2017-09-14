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
import AudioToolbox

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Collider types
    enum ColliderType: UInt32 {
        case mainCharacter = 1
        case aliens = 2
    }
    
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
    
    // Movement proportion
    private var jumpImpulseToPercentOfScreenHeight: CGFloat = 0.08
    private var leftRightImpulseToPercentOfScreenHeight: CGFloat = 0.028
    private var leftRightMovementOfPercentOfScreenWidth: CGFloat = 0.15
    
    // Score
    var aliensKilled = 0
    var score = 0
    var shotsFired = 0
    
    // Death
    var playerIsDead = false
    var reloading = false
    
    // Sound
    var punchSoundEffect : AVAudioPlayer?
    var backgroundMusic : AVAudioPlayer?
    var bulletSoundEffect : AVAudioPlayer?
    
    // Arrays
    var playerBulletArray: ArrayReference<SKBulletsNode> = ArrayReference()
    var alienArray: ArrayReference<SKAlienNode> = ArrayReference()
    var enemyCowboyArray: ArrayReference<SKEnemyCowboyNode> = ArrayReference()
    var enemyBulletArray: ArrayReference<SKBulletsNode> = ArrayReference()
    var textureMatrix: [[SKTexture?]]? = [[SKTexture?]](repeating: [SKTexture?](repeating: nil, count: 4), count: 3)
    
    // MARK: Did Move to View
    override func didMove(to view: SKView) {
        // Setup Contact Delegate
        self.physicsWorld.contactDelegate = self
        
        loadTextureArray()
        
        // Load elements
        loadBarrier()
        loadBackground()
        setUpSound()
        loadMainCharacter(withTexture: jimFacingRightTexture)
        setUpScoreLabel()
        setOverScreen()
        
        // Spawn enemies
        spawnAlien()
        dispatchEnemyCowboys()
    }
    
    // MARK: Load Texture Matrix
    func loadTextureArray() {
        for enemy in 1...3 {
            for stage in 0...3 {
                textureMatrix?[enemy-1][stage] = SKTexture(imageNamed: "spacesprite\(enemy)-\(stage).png")
            }
        }
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
        
        self.mainCharacter.size.width = 46.7
        self.mainCharacter.size.height = self.mainCharacter.size.width * #imageLiteral(resourceName: "jimCharacR").size.height / #imageLiteral(resourceName: "jimCharacR").size.width
        
        let characterCenter = CGPoint(x: self.mainCharacter.size.width / 2, y: self.mainCharacter.size.height / 2)
        
        self.mainCharacter.physicsBody = SKPhysicsBody(rectangleOf: self.mainCharacter.size,
                                                       center: characterCenter)
        
        self.mainCharacter.physicsBody?.allowsRotation = false
        self.mainCharacter.physicsBody?.isDynamic = true
        
        self.mainCharacter.physicsBody?.categoryBitMask = ColliderType.mainCharacter.rawValue
        self.mainCharacter.physicsBody?.contactTestBitMask = ColliderType.aliens.rawValue
        self.mainCharacter.physicsBody?.collisionBitMask = ColliderType.aliens.rawValue
        
        self.addChild(mainCharacter)
        
        self.bloodParticle?.particleBirthRate = 0
        self.bloodParticle?.position = characterCenter
        self.bloodParticle?.zPosition = -1
        self.mainCharacter.addChild(bloodParticle!)
    }
    
    // MARK: Audio Components
    func setUpSound() {
        let punchSound = URL(fileURLWithPath: Bundle.main.path(forResource: "punch", ofType: "wav")!)
        let music = URL(fileURLWithPath: Bundle.main.path(forResource: "FiveArmies", ofType: "mp3")!)
        
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
    
    // MARK: Load Score Display
    func setUpScoreLabel() {
        scoreLabel.fontName = "kenpixel"
        scoreLabel.fontSize = self.frame.size.height / 10
        scoreLabel.text = "0"
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height * 0.85)
        self.addChild(scoreLabel)
    }

    // MARK: Setup Death Screen
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
        
        deathScore.text = "Points"
        deathScore.fontName = "kenpixel"
        deathScore.fontSize = self.frame.size.height / 10
        deathScore.fontColor = UIColor.black
        deathScore.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        deathScore.zPosition = 15
        
        self.overScreen.addChild(deathScore)
    }
    
    // MARK: Alien Spawning
    func spawnAlien() {
        let alien = SKAlienNode()
        alien.spawn(withTextureSeries: textureMatrix![Int(arc4random_uniform(3))] as [SKTexture?],
                    inArray: alienArray,
                    withWidthRatioOf: 0.1,
                    avoidingNode: self.mainCharacter,
                    inScene: self)
        
        alien.physicsBody?.categoryBitMask = ColliderType.aliens.rawValue
        alien.physicsBody?.contactTestBitMask = ColliderType.mainCharacter.rawValue
        alien.physicsBody?.collisionBitMask = ColliderType.aliens.rawValue
    }
    
    // MARK: Dispatch Enemy Cowboys
    func dispatchEnemyCowboys() {
        let enemyCowboy = SKEnemyCowboyNode()
        enemyCowboy.dispatch(
            withWidthComparedToScreen: 0.07,
            withLeftTexture: enemyCowboyLeftTexture,
            withRightTexture: enemyCowboyRightTexture,
            toArray: enemyCowboyArray,
            withBulletsIn: enemyBulletArray,
            avoiding: self.mainCharacter,
            inScene: self)
    }
    
    
    // MARK: Update the Game
    override func update(_ currentTime: TimeInterval) {
        if playerIsDead {return}
        // Called before each frame is rendered
        moveAliens()
        trackBulletToAlienCollision()
        enemyCowboysAim()
        trackBulletToEnemyCowboyCollision()
        trackEnemyBulletToPlayerCollision()
    }
    
    // MARK: Move Aliens
    func moveAliens() {
        for a in alienArray.array! {
            a.trackCharacter(track: self.mainCharacter)
        }
    }
    
    // MARK: Watching for Bullet to Alien Collision
    func trackBulletToAlienCollision() {
        for b in playerBulletArray.array! {
            for a in alienArray.array! {
                if b.intersects(a) {
                    b.remove()
                    a.deteriorate()
                }
            }
        }
    }
    
    // MARK: Make Enemy Cowboys Aim at Player
    func enemyCowboysAim() {
        for c in enemyCowboyArray.array! {
            c.aim(at: self.mainCharacter)
        }
    }
    
    // MARK: Player Bullet to Enemy Cowboy Collision
    func trackBulletToEnemyCowboyCollision() {
        for b in playerBulletArray.array! {
            for c in enemyCowboyArray.array! {
                if b.intersects(c) {
                    b.remove()
                    c.didGetShot()
                    score += 2
                    self.scoreLabel.text = "\(score)"
                }
            }
        }
    }
    
    // MARK: Track Enemy Bullets to Player Collision
    func trackEnemyBulletToPlayerCollision() {
        for b in enemyBulletArray.array! {
            if b.intersects(self.mainCharacter) {
                playerDidDie()
            }
        }
    }
    
    // MARK: Character Movement
    func moveLeft() {
        if playerIsDead {return}
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: -19, dy: 0))
        self.mainCharacter.texture = jimFacingLeftTexture
    }
    
    func moveRight() {
        if playerIsDead {return}
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: 19, dy: 0))
        self.mainCharacter.texture = jimFacingRightTexture
    }
    
    func jump() {
        if playerIsDead {return}
        if self.mainCharacter.position.y < self.frame.size.height * 0.5 {
            self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 55))
        }
    }
    
    
    // MARK: Shoot Function
    func shoot() {
        if playerIsDead || reloading {return}
        
        if shotsFired >= 5 && !reloading {
            reloadGun()
            return
        }
        
        let bullet = SKBulletsNode(texture: bulletTexture)
        
        shotsFired += 1
        
        if self.mainCharacter.texture == jimFacingLeftTexture {
            bullet.shoot(from: self.mainCharacter,
                         to: .left,
                         fromPercentOfWidth: 0.8,
                         fromPercentOfHeight: 0.35,
                         toArray: playerBulletArray,
                         inScene: self)
            
        } else if self.mainCharacter.texture == jimFacingRightTexture {
            bullet.shoot(from: self.mainCharacter,
                         to: .right,
                         fromPercentOfWidth: 0.8,
                         fromPercentOfHeight: 0.35,
                         toArray: playerBulletArray,
                         inScene: self)
        }
    }
    
    // Reload Gun
    func reloadGun() {
        
        self.reloading = true
        run(SKAction.playSoundFileNamed("reload.mp3", waitForCompletion: false))
        
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.shotsFired = 0
            self.reloading = false
        }
        
    }
    
    // MARK: Player Did Die
    func playerDidDie() {
        backgroundMusic?.stop()
        backgroundMusic?.currentTime = 0.0
        shotsFired = 0
        
        punchSoundEffect?.play()
        
        
        self.mainCharacter.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.bloodParticle?.particleBirthRate = 400
        
        self.scoreLabel.text = "Game Over"
        self.scoreLabel.fontColor = UIColor.red
        
        self.playerIsDead = true
        self.reloading = false
        
        self.deathScore.text = "\(self.score) points"
        if self.score == 1 {self.deathScore.text = "1 point"}
        self.overScreen.run(SKAction.fadeIn(withDuration: 0.5))
        
    }
    
    // MARK: Reinitialize
    func restartGame() {
        // Reset Variables
        self.scoreLabel.fontColor = UIColor.white
        self.scoreLabel.text = "0"
        
        self.aliensKilled = 0
        self.score = 0
        
        self.playerIsDead = false
        self.bloodParticle?.particleBirthRate = 0
        
        // Reset Player Properties
        self.mainCharacter.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.5)
        self.mainCharacter.texture = jimFacingRightTexture
        
        // Remove All Aliens
        for a in alienArray.array! {
            a.remove()
        }
        
        // Remove All Bullets
        for b in playerBulletArray.array! {
            b.remove()
        }
        
        // Remove All Enemy Cowboys
        for c in enemyCowboyArray.array! {
            c.remove()
        }
        
        // Remove All Enemy Bullets
        for eb in enemyBulletArray.array! {
            eb.remove()
        }
        
        // Hide OverScreen
        self.overScreen.run(SKAction.fadeOut(withDuration: 0.5), completion: {
            self.spawnAlien()
            self.dispatchEnemyCowboys()
            
            // Start Music
            self.backgroundMusic?.play()
        })
    }
    
    
    // MARK: Detect Player to Alien Collision
    func didBegin(_ contact: SKPhysicsContact) {
        if playerIsDead {return}
        
        var player: SKSpriteNode?
        var alien: SKAlienNode?
        
        if contact.bodyA.categoryBitMask == ColliderType.aliens.rawValue && contact.bodyB.categoryBitMask == ColliderType.mainCharacter.rawValue {
            
            alien = contact.bodyA.node as? SKAlienNode
            player = contact.bodyB.node as? SKSpriteNode
            
        } else if contact.bodyA.categoryBitMask == ColliderType.mainCharacter.rawValue && contact.bodyB.categoryBitMask == ColliderType.aliens.rawValue {
            
            player = contact.bodyA.node as? SKSpriteNode
            alien = contact.bodyB.node as? SKAlienNode
            
        } else {
            return
        }
        
        if (alien?.didDamage(to: player!))! {
            playerDidDie()
        }
        
    }
    
    // MARK: When Touches Begin
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            print("Tapped \(t.location(in: self))")
            
            if !playerIsDead {return}
                
            for i in self.nodes(at: t.location(in: self)) {
                if i.name == "overScreen" {
                    self.restartGame()
                }
            }
            
        }
    }
    
    // MARK: End All Activity
    func endAll() {
        self.backgroundMusic?.stop()
        self.punchSoundEffect?.stop()
        self.backgroundMusic = nil
        self.punchSoundEffect = nil
        self.textureMatrix = nil
        self.removeAllActions()
        self.removeAllChildren()
        for a in alienArray.array! {
            a.gameScene = nil
            a.remove()
        }
        for b in playerBulletArray.array! {
            b.remove()
        }
        for c in enemyCowboyArray.array! {
            c.remove()
        }
        for eb in enemyBulletArray.array! {
            eb.remove()
        }
    }
    
    deinit {
        print("Deinitialized GameScene")
    }
}
