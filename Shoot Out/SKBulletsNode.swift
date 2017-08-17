import SpriteKit
import GameplayKit
import AVFoundation

// MARK: Bullet Class
class SKBulletsNode: SKSpriteNode {
    
    var gameScene: SKScene?
    var parentArray: ArrayReference<SKBulletsNode>? = ArrayReference()
    var hasRemoved = false
    
    // Shoot
    func shoot(from character: SKSpriteNode,
               to direction: Direction,
               fromPercentOfWidth xPercent: CGFloat,
               fromPercentOfHeight yPercent: CGFloat,
               toArray array: ArrayReference<SKBulletsNode>,
               inScene scene: SKScene) {
        
        self.gameScene = scene
        self.parentArray = array
        
        self.anchorPoint = CGPoint.zero
        self.size.width = character.size.width / 12
        self.size.height = self.size.width
        self.position = CGPoint(x: character.position.x + (character.size.width * xPercent),
                                y: character.position.y + (character.size.height * yPercent))
        self.zPosition = 1
        
        scene.addChild(self)
        parentArray!.array!.append(self)
        
        self.run(SKAction.playSoundFileNamed("GunShot.mp3", waitForCompletion: false))
        
        let translate = { (translationFunction: (CGFloat, CGFloat) -> CGFloat) in
            self.run(SKAction.moveTo(x: translationFunction(self.position.x,
                                                            self.gameScene!.frame.size.width), duration: 1.5), completion: {
                if !self.hasRemoved {
                    self.remove()
                }
            })
        }
        
        switch direction {
            case .left:
                translate({ (a, b) in a - b }) // Subtract X
            case .right:
                translate({ (a, b) in a + b }) // Add X
        }
    }
    
    // Remove from GameScene and bulletArray
    func remove() {
        if !self.hasRemoved {
            self.parentArray!.array!.remove(at: parentArray!.array!.index(of: self)!)
            
            self.texture = nil
            self.hasRemoved = true
            self.gameScene = nil
            
            self.parentArray = nil
            
            self.removeAllActions()
            self.removeFromParent()
        }
    }
    
    deinit {
        print("Deinitialized bullet at \(Date())")
    }
}
