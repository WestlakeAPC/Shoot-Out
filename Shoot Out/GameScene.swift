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
    
    // Bullet array
    var playerBulletArray = [SKBulletsNode?](repeating: nil, count: 0)
    
    // MARK: Did Move to View
    override func didMove(to view: SKView) {
        // Load elements
        loadBarrier()
        loadMainCharacter(withTexture: jimFacingRightTexture)
        
    }
    
    // MARK: Load Barrier
    func loadBarrier() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0,y: self.frame.size.height * 0.25, width: self.frame.size.width, height: self.frame.size.height))
        self.physicsBody?.isDynamic = false
        //self.physicsWorld.gravity = CGVector(dx: 0,dy: 0)
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
        playerBulletArray.append(bullet)
        
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

// MARK: Bullet Clasee
class SKBulletsNode: SKSpriteNode {
    
    var gameScene: GameScene?
    var locatedInArray: [SKBulletsNode?] = []
    var hasRemoved = false
    
    // Shoot
    func shoot(from character: SKSpriteNode, to direction: String, fromPercentOfWidth xPercent: CGFloat, fromPercentOfHeight yPercent: CGFloat, addToArray array: [SKBulletsNode?], inScene scene: GameScene) {
        
        self.gameScene = scene
        self.locatedInArray = array
        
        self.anchorPoint = CGPoint.zero
        self.size.width = character.size.width / 10
        self.size.height = self.size.width
        self.position = CGPoint(x: character.position.x + (character.size.width * xPercent) , y: character.position.y + (character.size.height * yPercent))
        self.zPosition = 1
        
        //self.locatedInArray.append(self)
        scene.addChild(self)
        
        print("Located: \n\n\(self.locatedInArray) \n\n\n\(gameScene?.playerBulletArray)!)")
        
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
            _ = gameScene?.playerBulletArray.remove(at: (gameScene?.playerBulletArray.index(where: { $0 == self }))!)
            self.hasRemoved = true
        }
        
    }
    
}
