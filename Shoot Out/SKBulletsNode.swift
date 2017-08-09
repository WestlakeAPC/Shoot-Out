import SpriteKit
import GameplayKit
import AVFoundation

// MARK: Bullet Class
class SKBulletsNode: SKSpriteNode {
    
    var gameScene: SKScene?
    var parentArray: NSMutableArray? = []
    var hasRemoved = false
    
    
    // Shoot
    func shoot(from character: SKSpriteNode,
               to direction: String,
               fromPercentOfWidth xPercent: CGFloat,
               fromPercentOfHeight yPercent: CGFloat,
               addToArray array: NSMutableArray,
               inScene scene: SKScene) {
        
        self.gameScene = scene
        self.parentArray = array
        self.parentArray?.adding(self)
        
        self.anchorPoint = CGPoint.zero
        self.size.width = character.size.width / 12
        self.size.height = self.size.width
        self.position = CGPoint(x: character.position.x + (character.size.width * xPercent) , y: character.position.y + (character.size.height * yPercent))
        self.zPosition = 1
        
        scene.addChild(self)
        parentArray?.add(self)
        
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
            self.parentArray?.remove(self)
            
            self.texture = nil
            self.parentArray = nil
            self.hasRemoved = true
            self.gameScene = nil
            
            self.removeAllActions()
            self.removeFromParent()
        }
    }
    
    deinit {
        print("Deinitialized bullet at \(Date())")
    }
}
