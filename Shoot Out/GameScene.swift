//
//  GameScene.swift
//  Shoot Out
//
//  Created by Joseph Jin on 7/21/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // Collider Type Enumeration
    enum ColliderType: UInt32 {
        
        case mainCharacter = 1
        case aliens = 2
        
    }
    
    // View Controller
    var viewController: UIViewController?
    
    // Spritekit nodes
    var mainCharacter = SKSpriteNode()
    var theGround = SKNode()
    var scoreLabel = SKLabelNode()
    var overScreen = SKShapeNode()
    var deathScore = SKLabelNode()
    var bloodParticle = SKEmitterNode(fileNamed: "Blood")
    
    // Textures
    private var jimFacingRightTexture = SKTexture(imageNamed: "jimCharacR.png")
    private var jimFacingLeftTexture = SKTexture(imageNamed: "jimCharacL.png")
    private var enemyCowboyRightTexture = SKTexture(imageNamed: "jimCharacR.png")
    private var enemyCowboyLeftTexture = SKTexture(imageNamed: "jimCharacL.png")
    var bulletTexture = SKTexture(imageNamed: "bullet.png")
    
    // Movement proportion
    private var jumpImpulseToPercentOfScreenHeight: CGFloat = 0.08
    private var leftRightImpulseToPercentOfScreenHeight: CGFloat = 0.028
    private var leftRightMovementOfPercentOfScreenWidth: CGFloat = 0.15
    
    // Score
    var aliensKilled = 0
    var score = 0
    
    // Death
    var playerIsDead = false
    
    // Arrays
    var playerBulletArray: NSMutableArray = []
    var alienArray: NSMutableArray = []
    var enemyCowboyArray: NSMutableArray = []
    var enemyBulletArray: NSMutableArray = []
    var textureMatrix = [[SKTexture?]](repeating: [SKTexture?](repeating: nil, count: 4), count: 3)
    
    // MARK: Did Move to View
    override func didMove(to view: SKView) {
        print(self)
        //Setup Contact Delegate
        self.physicsWorld.contactDelegate = self
        
        // Load Texture Array
        loadTextureArray()
        
        // Load elements
        loadBarrier()
        loadBackground()
        loadMainCharacter(withTexture: jimFacingRightTexture)
        setUpScoreLabel()
        setOverScreen()
        
        // Spawn Enemies
        spawnAlien()
        dispatchEnemyCowboys()
    }
    
    // MARK: Load Texture Matrix
    func loadTextureArray() {
        for enemy in 1...3 {
            for stage in 0...3 {
                textureMatrix[enemy-1][stage] = SKTexture(imageNamed: "spacesprite\(enemy)-\(stage).png")
            }
        }
    }
    
    // MARK: Load Barrier
    func loadBarrier() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0,y: self.frame.size.height * 0.25, width: self.frame.size.width, height: self.frame.size.height))
        self.physicsBody?.isDynamic = false
    }
    
    // MARK: Load Background
    func loadBackground() {
        let backGroundImage: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "background.png"))
        
        backGroundImage.anchorPoint = CGPoint.zero
        backGroundImage.position = CGPoint(x: 0, y: 0)
        backGroundImage.zPosition = 0
        backGroundImage.size.width = self.frame.size.width
        backGroundImage.size.height = backGroundImage.size.width * 3/4
        
        
        self.addChild(backGroundImage)
    }
    
    // MARK: Load Main Character
    func loadMainCharacter(withTexture texture: SKTexture) {
        self.mainCharacter = SKSpriteNode(texture: texture)
        
        self.mainCharacter.anchorPoint = CGPoint.zero
        self.mainCharacter.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.5)
        self.mainCharacter.zPosition = 3
        
        self.mainCharacter.size.width = self.frame.size.width * 0.05
        self.mainCharacter.size.height = self.mainCharacter.size.width * 8 / 5
        
        self.mainCharacter.physicsBody = SKPhysicsBody(rectangleOf: self.mainCharacter.size, center: CGPoint(x: self.mainCharacter.size.width * 0.5, y: self.mainCharacter.size.height * 0.5))
        
        self.mainCharacter.physicsBody?.allowsRotation = false
        self.mainCharacter.physicsBody?.isDynamic = true
        
        self.mainCharacter.physicsBody?.categoryBitMask = ColliderType.mainCharacter.rawValue
        self.mainCharacter.physicsBody?.contactTestBitMask = ColliderType.aliens.rawValue
        self.mainCharacter.physicsBody?.collisionBitMask = ColliderType.aliens.rawValue
        
        self.addChild(mainCharacter)
        
        self.bloodParticle?.particleBirthRate = 0
        self.bloodParticle?.position = CGPoint(x: self.mainCharacter.size.width / 2, y: self.mainCharacter.size.height / 2)
        self.bloodParticle?.zPosition = -1
        self.mainCharacter.addChild(bloodParticle!)
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
        
        self.overScreen = SKShapeNode(rect: CGRect(origin: CGPoint(x: self.frame.size.width / 4, y: self.frame.size.height / 4), size: CGSize(width: self.frame.size.width / 2, height: self.frame.height / 2)))
        
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
        alien.spawn(withTextureSeries: textureMatrix, addToArray: alienArray, widthToScreenWidthOf: 0.1, avoidElement: self.mainCharacter, inScene: self)
        
        alien.physicsBody?.categoryBitMask = ColliderType.aliens.rawValue
        alien.physicsBody?.contactTestBitMask = ColliderType.mainCharacter.rawValue
        alien.physicsBody?.collisionBitMask = ColliderType.aliens.rawValue
    }
    
    // MARK: Dispatch Enemy Cowboys
    func dispatchEnemyCowboys() {
        let enemyCowboy = SKEnemyCowboyNode()
        enemyCowboy.dispatch(withWidthComparedToScreen: 0.05, withLeftTexture: enemyCowboyLeftTexture, withRightTexture: enemyCowboyRightTexture, toArray: enemyCowboyArray, storyBulletsIn: enemyBulletArray, inScene: self)
    }
    
    
    // MARK: Update the Game
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        moveAliens()
        trackBulletToAlienCollision()
        enemyCowboysAim()
        trackBulletToEnemyCowboyCollision()
    }
    
    // MARK: Move Aliens
    func moveAliens() {
        if playerIsDead {return}
        for a in (alienArray as NSArray as! [SKAlienNode]) {
            a.trackCharacter(track: self.mainCharacter)
        }
    }
    
    // MARK: Watching for Bullet to Alien Collision
    func trackBulletToAlienCollision() {
        for b in (playerBulletArray as NSArray as! [SKBulletsNode]) {
            for a in (alienArray as NSArray as! [SKAlienNode]) {
                if b.intersects(a) {
                    b.remove()
                    a.deteriorate()
                }
            }
        }
    }
    
    // MARK: Make Enemy Cowboys Aim at Player
    func enemyCowboysAim() {
        for c in (enemyCowboyArray as NSArray as! [SKEnemyCowboyNode]) {
            c.aim(at: self.mainCharacter)
        }
    }
    
    // MARK: Player Bullet to Cowboy Collision
    func trackBulletToEnemyCowboyCollision() {
        for b in (playerBulletArray as NSArray as! [SKBulletsNode]) {
            for c in (enemyCowboyArray as NSArray as! [SKEnemyCowboyNode]) {
                if b.intersects(c) {
                    b.remove()
                    c.didGetShot()
                    score += 2
                }
            }
        }
    }
    
    // MARK: Character Movement
    func moveLeft() {
        if playerIsDead {return}
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * -leftRightImpulseToPercentOfScreenHeight,dy: 0))
        self.mainCharacter.texture = jimFacingLeftTexture
    }
    
    func moveRight() {
        if playerIsDead {return}
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * leftRightImpulseToPercentOfScreenHeight,dy: 0))
        self.mainCharacter.texture = jimFacingRightTexture
    }
    
    func jump() {
        if playerIsDead {return}
        if self.mainCharacter.position.y < self.frame.size.height * 0.5 {
            self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: 0,dy: self.frame.size.height * jumpImpulseToPercentOfScreenHeight))
        }
    }
    
    
    // MARK: Shoot Function
    func shoot() {
        if playerIsDead {return}
        let bullet = SKBulletsNode(texture: bulletTexture)
        
        if self.mainCharacter.texture == jimFacingLeftTexture {
            bullet.shoot(from:
                self.mainCharacter, to: "left", fromPercentOfWidth: 0.5, fromPercentOfHeight: 0.65, addToArray: playerBulletArray, inScene: self)
            
        } else if self.mainCharacter.texture == jimFacingRightTexture {
            bullet.shoot(from: self.mainCharacter, to: "right", fromPercentOfWidth: 0.5, fromPercentOfHeight: 0.65, addToArray: playerBulletArray, inScene: self)
        }
    }
    
    // MARK: Player Did Die
    func playerDidDie() {
        self.mainCharacter.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.bloodParticle?.particleBirthRate = 750
        
        self.scoreLabel.text = "Game Over"
        self.scoreLabel.fontColor = UIColor.red
        
        self.playerIsDead = true
        
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
        for a in (alienArray as NSArray as! [SKAlienNode]) {
            a.remove()
        }
        
        // Remove All Bullets
        for b in (playerBulletArray as NSArray as! [SKBulletsNode]) {
            b.remove()
        }
        
        // Remove All Enemy Cowboys
        for c in (enemyCowboyArray as NSArray as! [SKEnemyCowboyNode]) {
            c.remove()
        }
        
        // Hide OverScreen
        self.overScreen.run(SKAction.fadeOut(withDuration: 0.5), completion: {
            self.spawnAlien()
            self.dispatchEnemyCowboys()
        })
    }
    
    
    // MARK: Detect Player to Alien Collision
    func didBegin(_ contact: SKPhysicsContact) {
        if playerIsDead {return}
        
        var player: SKSpriteNode?
        var alien: SKAlienNode?
        
        if contact.bodyA.categoryBitMask == ColliderType.aliens.rawValue && contact.bodyB.categoryBitMask == ColliderType.mainCharacter.rawValue {
            
            print("Contact Case A")
            
            alien = contact.bodyA.node as? SKAlienNode
            player = contact.bodyB.node as? SKSpriteNode
            
        } else if contact.bodyA.categoryBitMask == ColliderType.mainCharacter.rawValue && contact.bodyB.categoryBitMask == ColliderType.aliens.rawValue {
            
            print("Contact Case B")
            
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
    
    
}



// MARK: Bullet Class
class SKBulletsNode: SKSpriteNode {
    
    var gameScene: GameScene?
    var parentArray: NSMutableArray = []
    var hasRemoved = false
    
    // Shoot
    func shoot(from character: SKSpriteNode, to direction: String, fromPercentOfWidth xPercent: CGFloat, fromPercentOfHeight yPercent: CGFloat, addToArray array: NSMutableArray, inScene scene: GameScene) {
        
        self.gameScene = scene
        self.parentArray = array
        self.parentArray.adding(self)
        
        self.anchorPoint = CGPoint.zero
        self.size.width = character.size.width / 10
        self.size.height = self.size.width
        self.position = CGPoint(x: character.position.x + (character.size.width * xPercent) , y: character.position.y + (character.size.height * yPercent))
        self.zPosition = 1
        
        scene.addChild(self)
        parentArray.add(self)
        
        if direction == "left" {
            self.run(SKAction.moveTo(x: (self.position.x - (gameScene?.frame.size.width)!), duration: 1.5), completion: {
                if !self.hasRemoved {
                    self.remove()
                }
            })
            
        } else if direction == "right" {
            self.run(SKAction.moveTo(x: (self.position.x + (gameScene?.frame.size.width)!), duration: 1.5), completion: {
                if !self.hasRemoved {
                    self.remove()
                }
            })
            
        } else {
            print("Invalid Direction")
        }
    }
    
    // Check intersection
    func doesIntersectWith(element object: SKSpriteNode) -> Bool {
        return self.intersects(object)
    }
    
    // Remove from GameScene and bulletArray
    func remove() {
        if !self.hasRemoved {
            self.removeFromParent()
            self.parentArray.remove(self)
            self.hasRemoved = true
        }
        
    }
}



// MARK: Alien Class
class SKAlienNode: SKSpriteNode {
    
    // MARK: Deterioration stages
    enum Deterioration {
        case perfectShape
        case goodShape
        case badShape
        case finishHim
    }
    
    // MARK: Internal enemy state
    var deteriorationStage: Deterioration = .perfectShape
    var gameScene: GameScene?
    var fullTextureArray: [[SKTexture?]] = []
    var textureArray: [SKTexture] = []
    var parentArray: NSMutableArray = []
    var allowMovement: Bool = false
    
    // MARK: Spawn
    func spawn(withTextureSeries textures: [[SKTexture?]], addToArray inArray: NSMutableArray, widthToScreenWidthOf xProp: CGFloat, avoidElement character: SKSpriteNode, inScene gameScene: GameScene){
        
        self.parentArray = inArray
        // Set Max Aliens At Any Given Time
        if self.parentArray.count >= 7 {return}
        
        self.fullTextureArray = textures
        
        self.textureArray = textures[Int(arc4random_uniform(3))] as! [SKTexture]
        self.texture = textureArray[0]
        self.gameScene = gameScene
        
        self.size.width = gameScene.frame.size.width * xProp
        self.size.height = self.size.width * 2 / 3
        
        self.anchorPoint = CGPoint.zero
        
        // Avoid Landing on Player's Head
        repeat {
            self.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(gameScene.size.width) - UInt32(self.size.width))), y: gameScene.frame.height * 1.25 - self.size.height)
        } while self.position.x < (character.position.x + character.size.width + gameScene.frame.size.width / 6) && (self.position.x + self.size.width) > (character.position.x - character.size.width - gameScene.frame.size.width / 6)
        
        self.zPosition = 3
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width * 0.7, height: self.size.height * 0.8), center: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.35))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = true
        
        gameScene.addChild(self)
        parentArray.add(self)
        
        self.run(SKAction.wait(forDuration: TimeInterval(1)), completion: {
            self.allowMovement = true
        })
        
    }
    
    // MARK: Track Character
    func trackCharacter(track character: SKSpriteNode) {
        if !allowMovement {return}
        
        // Move right if character is at right of self
        if (self.position.x + self.size.width) < (character.position.x + character.size.width) {
            self.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * 0.007, dy: 0))
            
        // Move left if character is at left of self
        } else if (self.position.x - character.size.width * 0.2) > (character.position.x - character.size.width) {
            self.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * -0.007, dy: 0))
            
        }
    }
    
    // MARK: Check for Contact
    func didDamage(to element: SKSpriteNode) -> Bool {
        
        // If Head is Stepped
        if ((self.position.y + self.size.height * 0.6) < element.position.y) {
            
            self.deteriorate()
            gameScene?.jump()
            return false
            
        }
        
        return true
        
    }
    
    // MARK: Make Enemy Deteriorate
    func deteriorate() {
        switch (deteriorationStage) {
            case .perfectShape:
                deteriorationStage = .goodShape
                self.texture = textureArray[1]
            
            case .goodShape:
                deteriorationStage = .badShape
                self.texture = textureArray[2]
                
            case .badShape:
                deteriorationStage = .finishHim
                self.texture = textureArray[3]
            
            case .finishHim:
                if (gameScene?.playerIsDead)! {return}
                self.isHidden = false
                gameScene?.aliensKilled += 1
                gameScene?.score += 1
                gameScene?.scoreLabel.text = String(describing: (gameScene?.score)!)
                
                self.remove()
                
                gameScene?.spawnAlien()
                self.spawnStrategically()

        }
    }
    
    // MARK: Spawn more enemies
    func spawnStrategically() {
        if (gameScene?.aliensKilled)! % 8 == 0 {
            gameScene?.dispatchEnemyCowboys()
        }
        
        switch (parentArray.count) {
        case 1:
            if (gameScene?.aliensKilled)! >= 5 {
                gameScene?.spawnAlien()
            }
        case 2:
            if (gameScene?.aliensKilled)! >= 15 {
                gameScene?.spawnAlien()
            }
        case 3:
            if (gameScene?.aliensKilled)! >= 25 {
                gameScene?.spawnAlien()
            }
        case 4:
            if (gameScene?.aliensKilled)! >= 40 {
                gameScene?.spawnAlien()
            }
        case 5:
            if (gameScene?.aliensKilled)! >= 55 {
                gameScene?.spawnAlien()
            }
        case 6:
            if (gameScene?.aliensKilled)! >= 75 {
                gameScene?.spawnAlien()
            }
        default:
            return
        }
        
    }
    
    // MARK: Delete Alien
    func remove() {
        self.parentArray.remove(self)
        self.removeFromParent()
    }
    
}


// MARK: Enemy Cowboy Class
class SKEnemyCowboyNode: SKSpriteNode {
    
    var gameScene: GameScene?
    var parentArray: NSMutableArray = []
    var bulletsArray: NSMutableArray = []
    var leftTexture: SKTexture?
    var rightTexture: SKTexture?
    var hasLanded = false
    var canShoot = true
    
    // Dispatch EnemyCowboy
    func dispatch(withWidthComparedToScreen widthScale: CGFloat, withLeftTexture left: SKTexture, withRightTexture right: SKTexture, toArray parentArray: NSMutableArray, storyBulletsIn bulletsArray: NSMutableArray, inScene scene: GameScene) {
        
        self.gameScene = scene
        self.parentArray = parentArray
        self.bulletsArray = bulletsArray
        
        self.leftTexture = left
        self.rightTexture = right
        
        self.parentArray.add(self)
        
        self.texture = self.rightTexture
        
        self.size.width = self.gameScene!.frame.size.width * widthScale
        self.size.height = self.size.width * (self.rightTexture?.size().height)! / (self.rightTexture?.size().width)!
        
        self.anchorPoint = CGPoint.zero
        self.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32((gameScene?.size.width)! - self.size.width))), y: (gameScene?.size.height)! * 1.25 - self.size.height)
        self.zPosition = 2
        
        self.gameScene?.addChild(self)
        
        self.run(SKAction.moveTo(y: (self.gameScene?.frame.size.height)! * 0.25, duration: 0.5), completion: {
            self.hasLanded = true
            
            let waitBeforeShot = SKAction.wait(forDuration: 0.2)
            let shootAndWait = SKAction.repeat(SKAction.sequence([waitBeforeShot,SKAction.run({self.shootMainCharacter()})]), count: 3)
            let waitBeforeSeries = SKAction.wait(forDuration: 2)
            
            self.run(SKAction.repeatForever(
                SKAction.sequence([waitBeforeSeries, shootAndWait])
            ))
        })
        
    }
    
    // Aim at MainCharacter
    func aim(at Character: SKSpriteNode) {
        if Character.position.x > (self.position.x + self.size.width) {
            self.texture = self.rightTexture
        } else if (Character.position.x + Character.size.width) < self.position.x {
            self.texture = self.leftTexture
        }
    }
    
    // Shoot
    func shootMainCharacter() {
        if !canShoot {return}
        
        let enemyBullet = SKBulletsNode(texture: gameScene?.bulletTexture)
            
        if self.texture == self.leftTexture {
            enemyBullet.shoot(from: self, to: "left", fromPercentOfWidth: 0.5, fromPercentOfHeight: 0.65, addToArray: bulletsArray, inScene: self.gameScene!)
                
        } else if self.texture == self.rightTexture {
            enemyBullet.shoot(from: self, to: "right", fromPercentOfWidth: 0.5, fromPercentOfHeight: 0.65, addToArray: bulletsArray, inScene: self.gameScene!)
        }
    }
    
    // Getting Shot
    func didGetShot() {
        canShoot = false
        
        let particle = SKEmitterNode(fileNamed: "Blood")
        particle?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        particle?.zPosition = 1
        particle?.particleBirthRate = 100
        self.addChild(particle!)
        
        self.run(SKAction.moveTo(y: (gameScene?.frame.size.height)! * -0.5, duration: 0.5), completion: {self.remove()})
    }
    
    // Remove EnemyCowboy
    func remove() {
        self.parentArray.remove(self)
        self.removeFromParent()
    }
    
}
