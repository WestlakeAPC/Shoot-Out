//
//  GameScene.swift
//  Shoot Out
//
//  Created by Joseph Jin on 7/21/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Spritekit nodes
    var mainCharacter = SKSpriteNode()
    var theGround = SKNode()
    var scoreLabel = SKLabelNode()
    
    // Textures
    private var jimFacingRightTexture = SKTexture(imageNamed: "jimCharacR.png")
    private var jimFacingLeftTexture = SKTexture(imageNamed: "jimCharacL.png")
    private var bulletTexture = SKTexture(imageNamed: "bullet.png")
    
    // Movement proportion
    private var jumpImpulseToPercentOfScreenHeight: CGFloat = 0.08
    private var leftRightImpulseToPercentOfScreenHeight: CGFloat = 0.028
    private var leftRightMovementOfPercentOfScreenWidth: CGFloat = 0.15
    
    // Score
    var aliensKilled = 0
    var score = 0
    
    // Arrays
    var playerBulletArray: NSMutableArray = []
    var alienArray: NSMutableArray = []
    var textureMatrix = [[SKTexture?]](repeating: [SKTexture?](repeating: nil, count: 4), count: 3)
    
    // MARK: Did Move to View
    override func didMove(to view: SKView) {
        // Load Texture Array
        loadTextureArray()
        
        // Load elements
        loadBarrier()
        loadBackground()
        loadMainCharacter(withTexture: jimFacingRightTexture)
        setUpScoreLabel()
        
        // Spawn Alien
        spawnAlien()
    }
    
    // MARK: Update the Game
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        trackBulletToAlienCollision()
        moveAliens()
        testDeath()
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
        
        self.addChild(mainCharacter)
    }
    
    // MARK: Load Score Display
    func setUpScoreLabel() {
        scoreLabel.fontName = "04b_19"
        scoreLabel.fontSize = 40
        scoreLabel.text = "0"
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height - 60)
        self.addChild(scoreLabel)
    }
    
    // MARK: Alien Spawning
    func spawnAlien() {
        let alien = SKAlienNode()
        alien.spawn(withTextureSeries: textureMatrix, addToArray: alienArray, widthToScreenWidthOf: 0.1, avoidElement: self.mainCharacter, inScene: self)
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
    
    // MARK: Move Aliens
    func moveAliens() {
        for a in (alienArray as NSArray as! [SKAlienNode]) {
            a.trackCharacter(track: self.mainCharacter)
        }
    }
    
    // MARK: Test Death
    func testDeath() {
        //for a in (alienArray as NSArray as! [SKAlienNode]) {
        //    if a.intersects(self.mainCharacter) {
        //        self.scoreLabel.text = "Dead"
        //        print("You Died \(Date())")
        //    }
        //}
        
        if playerDamageByAlien() {
            print("You Died \(Date())")
            self.scoreLabel.text = "Dead"
        }
    }
    
    // MARK: Player to Alien Collision
    func playerDamageByAlien () -> Bool {
        
        for a in (alienArray as NSArray as! [SKAlienNode]) {
            if a.didContactPhysicsBody(with: self.mainCharacter) {
                return true
            }
        }
        
        return false
    }
    
    
    // MARK: Character Movement
    func moveLeft() {
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * -leftRightImpulseToPercentOfScreenHeight,dy: 0))
        self.mainCharacter.texture = jimFacingLeftTexture
    }
    
    func moveRight() {
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * leftRightImpulseToPercentOfScreenHeight,dy: 0))
        self.mainCharacter.texture = jimFacingRightTexture
    }
    
    func jump() {
        if self.mainCharacter.position.y < self.frame.size.height * 0.5 {
            self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: 0,dy: self.frame.size.height * jumpImpulseToPercentOfScreenHeight))
        }
    }
    
    
    // MARK: Shoot Function
    func shoot() {
        let bullet = SKBulletsNode(texture: bulletTexture)
        
        if self.mainCharacter.texture == jimFacingLeftTexture {
            bullet.shoot(from:
                self.mainCharacter, to: "left", fromPercentOfWidth: 0.5, fromPercentOfHeight: 0.65, addToArray: playerBulletArray, inScene: self)
            
        } else if self.mainCharacter.texture == jimFacingRightTexture {
            bullet.shoot(from: self.mainCharacter, to: "right", fromPercentOfWidth: 0.5, fromPercentOfHeight: 0.65, addToArray: playerBulletArray, inScene: self)
        }
    }

    
    // MARK: Debugging
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //print("Tapped \(t.location(in: self))")
        }
    }
    
}



// MARK: Bullet Clasee
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
        if self.parentArray.count >= 5 {return}
        
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
        } while self.position.x < (character.position.x + character.size.width * 1.5) && (self.position.x + self.size.width) > (character.position.x - character.size.width * 0.5)
        
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
    func didContactPhysicsBody(with element: SKSpriteNode) -> Bool {
        
        return (((self.position.x + self.size.width * 0.12) < (element.position.x + element.size.width)) && ((self.position.x + self.size.width * 0.88) > element.position.x)) && // Test X
            ((self.position.y < (element.position.y + element.size.height * 0.8)) && ((self.position.y + self.size.height) > element.position.y)) // Test Y
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
                self.isHidden = false
                gameScene?.aliensKilled += 1
                gameScene?.score += 1
                gameScene?.scoreLabel.text = String(describing: (gameScene?.score)!)
                
                _ = self.parentArray.remove(self)
                self.removeFromParent()
                
                gameScene?.spawnAlien()
                self.spawnStrategically()

        }
    }
    
    // MARK: Spawn more enemies
    func spawnStrategically() {
        switch (parentArray.count) {
        case 1:
            if (gameScene?.aliensKilled)! >= 10 {
                gameScene?.spawnAlien()
            }
        case 2:
            if (gameScene?.aliensKilled)! >= 30 {
                gameScene?.spawnAlien()
            }
        case 3:
            if (gameScene?.aliensKilled)! >= 45 {
                gameScene?.spawnAlien()
            }
        case 4:
            if (gameScene?.aliensKilled)! >= 60 {
                gameScene?.spawnAlien()
            }
        default:
            return
        }
        
    }
    
}
