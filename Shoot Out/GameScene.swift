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
    
    private var mainCharacter = SKSpriteNode()
    private var theGround = SKNode()
    
    // MARK: Did Move to View
    override func didMove(to view: SKView) {
        // Pass reference of self
        let vc = GameViewController()
        vc.setGameScene(scene: self)
        
        // Load elements
        loadGround()
        loadMainCharacter(withImage: "tempCharac.png")
        
    }
    
    func loadGround() {
        self.theGround.position = CGPoint(x: 0, y: self.frame.size.height * 0.25 - 1)
        
        self.theGround.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        self.theGround.physicsBody?.isDynamic = false
        
        self.addChild(theGround)
    }
    
    // MARK: Load Main Character
    func loadMainCharacter (withImage image: String) {
        self.mainCharacter = SKSpriteNode(texture: SKTexture(imageNamed: image))
        
        self.mainCharacter.anchorPoint = CGPoint.zero
        self.mainCharacter.position = CGPoint(x: self.frame.size.width * 0.3, y: self.frame.size.height * 0.5)
        
        self.mainCharacter.size.width = self.frame.size.width * 0.05
        self.mainCharacter.size.height = self.mainCharacter.size.width * 8 / 5
        
        self.mainCharacter.physicsBody = SKPhysicsBody(rectangleOf: self.mainCharacter.size)
        self.mainCharacter.physicsBody?.isDynamic = true
        
        self.addChild(mainCharacter)
    }
    
    
    // MARK: Character Movement
    func moveLeft() {
        print("moveLeft")
        self.mainCharacter.run(SKAction.moveBy(x: -100, y: 0, duration: 0.3))
    }
    
    func moveRight() {
        print("moveRight")
        self.mainCharacter.run(SKAction.moveBy(x: 100, y: 0, duration: 0.3))
    }
    
    func jump() {
        print("jump")
    }
    
    func shoot() {
        print("shoot")
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
