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
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    // Spritekit nodes
    private var mainCharacter = SKSpriteNode()
    private var theGround = SKNode()
    
    // Textures
    private var jimFacingRightTexture = SKTexture(imageNamed: "jimCharacR.png")
    private var jimFacingLeftTexture = SKTexture(imageNamed: "jimCharacL.png")
    private var bulletTexture = SKTexture(imageNamed: "bullet.png")
    
    // Movement proportion
    private var leftRightMovementOfPercentOfScreenWidth: CGFloat = 0.15
    private var jumpImpulseToPercentOfScreenHeight: CGFloat = 0.1
    private var leftRightImpulseToPercentOfScreenHeight: CGFloat = 0.1
    
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
        
        // Spawn Alien
        spawnAlien()
    }
    
    // MARK: Update the Game
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        trackBulletToAlienCollision()
        moveAliens()
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
    
    // MARK: Alien Spawning
    func spawnAlien() {
        let alien = SKAlienNode()
        alien.spawn(withTextureSeries: textureMatrix, addToArray: alienArray, widthToScreenWidthOf: 0.1, inScene: self)
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
    
    // MARK: Character Movement
    func moveLeft() {
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * -0.3 * leftRightImpulseToPercentOfScreenHeight,dy: 0))
        self.mainCharacter.texture = jimFacingLeftTexture
    }
    
    func moveRight() {
        self.mainCharacter.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * 0.3 * leftRightImpulseToPercentOfScreenHeight,dy: 0))
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
            print("Tapped \(t.location(in: self))")}
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
    
    // MARK: Spawn
    func spawn(withTextureSeries textures: [[SKTexture?]], addToArray inArray: NSMutableArray, widthToScreenWidthOf xProp: CGFloat, inScene gameScene: GameScene){
        
        self.fullTextureArray = textures
        
        self.textureArray = textures[Int(arc4random_uniform(3))] as! [SKTexture]
        self.texture = textureArray[0]
        self.parentArray = inArray
        self.gameScene = gameScene
        
        self.size.width = gameScene.frame.size.width * xProp
        self.size.height = self.size.width * 2 / 3
        
        self.anchorPoint = CGPoint.zero
        
        self.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(gameScene.size.width) - UInt32(self.size.width))), y: gameScene.frame.height * 1.25 - self.size.height)
        self.zPosition = 3
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = true
        
        gameScene.addChild(self)
        parentArray.add(self)
        
    }
    
    func trackCharacter(track character: SKSpriteNode) {
        // Move right if character is at right of self
        if (self.position.x + self.size.width) < character.position.x {
            self.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * 0.015, dy: 0.001))
            
        // Move left if character is at left of self
        } else if self.position.x > (character.position.x + character.size.width) {
            self.physicsBody?.applyImpulse(CGVector(dx: self.frame.size.width * -0.015, dy: 0.001))
            
        }
    }
    
    // MARK: Make enemy deteriorate.
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
                    _ = self.parentArray.remove(self)
                    self.removeFromParent()
                    gameScene?.spawnAlien()
        }
    }
}
