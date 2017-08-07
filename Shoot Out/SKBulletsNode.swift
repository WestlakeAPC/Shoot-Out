import SpriteKit
import GameplayKit
import AVFoundation

// MARK: Bullet Class
class SKBulletsNode: SKSpriteNode {
    
    var gameScene: GameScene?
    var parentArray: NSMutableArray = []
    var hasRemoved = false
    var bulletSoundEffect : AVAudioPlayer?
    
    
    // Shoot
    func shoot(from character: SKSpriteNode,
               to direction: String,
               fromPercentOfWidth xPercent: CGFloat,
               fromPercentOfHeight yPercent: CGFloat,
               addToArray array: NSMutableArray,
               inScene scene: GameScene) {
        
        self.gameScene = scene
        self.parentArray = array
        self.parentArray.adding(self)
        self.run(SKAction.playSoundFileNamed("DesertEagleShot.mp3", waitForCompletion: false))
        
        self.anchorPoint = CGPoint.zero
        self.size.width = character.size.width / 12
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
            self.gameScene = nil
        }
        
    }
}

