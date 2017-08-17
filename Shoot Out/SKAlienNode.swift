//
//  SKAlienNode.swift
//  Shoot Out
//
//  Created by Eli Bradley on 8/7/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

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
    var fullTextureArray: [[SKTexture?]]? = []
    var textureArray: [SKTexture]? = []
    var parentArray: ArrayReference<SKAlienNode>? = ArrayReference()
    var allowMovement: Bool = false
    
    // MARK: Spawn
    func spawn(withTextureSeries textures: [[SKTexture?]],
               inArray array: ArrayReference<SKAlienNode>,
               withWidthRatioOf xProp: CGFloat,
               avoidingNode character: SKSpriteNode,
               inScene gameScene: GameScene) {
        
        self.parentArray = array
        
        // Remove yourself if too many aliens.
        if self.parentArray!.array!.count >= 7 {
            self.remove()
            return
        }
        
        self.fullTextureArray = textures
        
        self.textureArray = textures[Int(arc4random_uniform(3))] as? [SKTexture]
        self.texture = textureArray?[0]
        self.gameScene = gameScene
        
        self.size.width = 67
        self.size.height = self.size.width * 2 / 3
        
        self.anchorPoint = CGPoint.zero
        
        // Avoid Landing on Player's Head
        repeat {
            self.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(gameScene.size.width) - UInt32(self.size.width))),
                                    y: gameScene.frame.height * 1.25 - self.size.height)
        } while self.position.x < (character.position.x + character.size.width + gameScene.frame.size.width / 6) &&
            (self.position.x + self.size.width) > (character.position.x - character.size.width - gameScene.frame.size.width / 6)
        
        self.zPosition = 3
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width * 0.7, height: self.size.height * 0.8),
                                         center: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.35))
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = true
        
        gameScene.addChild(self)
        parentArray!.array!.append(self)
        
        self.run(SKAction.wait(forDuration: TimeInterval(1)), completion: {
            self.allowMovement = true
        })
    }
    
    // MARK: Track Character
    func trackCharacter(track character: SKSpriteNode) {
        if !allowMovement {return}
        
        // Move right if character is at right of self
        if (self.position.x + self.size.width) < (character.position.x + character.size.width) {
            self.physicsBody?.applyImpulse(CGVector(dx: 0.47, dy: 0))
            
            // Move left if character is at left of self
        } else if (self.position.x - character.size.width * 0.2) > (character.position.x - character.size.width) {
            self.physicsBody?.applyImpulse(CGVector(dx: -0.47, dy: 0))
            
        }
    }
    
    // MARK: Check for Contact
    func didDamage(to element: SKSpriteNode) -> Bool {
        
        // If Head is Stepped
        if ((self.position.y + self.size.height * 0.6) < element.position.y) {
            
            self.deteriorate()
            gameScene?.jump()
            
            switch arc4random_uniform(999) % 3 {
            case 0:
                gameScene?.moveRight()
            case 1:
                gameScene?.moveLeft()
            default:
                return false
            }
            
            return false
            
        }
        
        return true
        
    }
    
    // MARK: Make Enemy Deteriorate
    func deteriorate() {
        switch (deteriorationStage) {
        case .perfectShape:
            deteriorationStage = .goodShape
            self.texture = textureArray?[1]
            
        case .goodShape:
            deteriorationStage = .badShape
            self.texture = textureArray?[2]
            
        case .badShape:
            deteriorationStage = .finishHim
            self.texture = textureArray?[3]
            
        case .finishHim:
            if (gameScene?.playerIsDead)! {return}
            self.isHidden = false
            gameScene?.aliensKilled += 1
            gameScene?.score += 1
            gameScene?.scoreLabel.text = String(describing: (gameScene?.score)!)
            
            self.spawnStrategically()
            gameScene?.spawnAlien()
            
            self.remove()
        }
    }
    
    // MARK: Spawn more enemies
    func spawnStrategically() {
        if (gameScene?.score)! % 8 == 0 {
            gameScene?.dispatchEnemyCowboys()
        }
        
        switch (parentArray!.array!.count) {
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
        self.parentArray!.array!.remove(at: parentArray!.array!.index(of: self)!)
        self.fullTextureArray = nil
        self.textureArray = nil
        
        self.parentArray = nil
        
        self.removeAllActions()
        self.removeFromParent()
    }
    
    deinit {
        print("Deinitialized alien at \(Date())")
    }
}
