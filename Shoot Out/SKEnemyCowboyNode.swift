import SpriteKit
import GameplayKit
import AVFoundation

// MARK: Enemy Cowboy Class
class SKEnemyCowboyNode: SKSpriteNode {
    
    var gameScene: GameScene?
    var parentArray: ArrayReference<SKEnemyCowboyNode>? = ArrayReference()
    var bulletsArray: ArrayReference<SKBulletsNode>? = ArrayReference()
    var leftTexture: SKTexture?
    var rightTexture: SKTexture?
    var hasLanded = false
    var canShoot = true
    var shot = false
    
    // Dispatch EnemyCowboy
    func dispatch(withWidthComparedToScreen widthScale: CGFloat,
                  withLeftTexture left: SKTexture,
                  withRightTexture right: SKTexture,
                  toArray parentArray: ArrayReference<SKEnemyCowboyNode>,
                  withBulletsIn bulletsArray: ArrayReference<SKBulletsNode>,
                  avoiding character: SKSpriteNode,
                  inScene scene: GameScene) {
        
        self.gameScene = scene
        self.parentArray = parentArray
        self.bulletsArray = bulletsArray
        
        self.leftTexture = left
        self.rightTexture = right
        
        self.parentArray!.array!.append(self)
        
        self.texture = self.rightTexture
        
        self.size.width = 46.7
        self.size.height = self.size.width * (self.rightTexture?.size().height)! / (self.rightTexture?.size().width)!
        
        self.anchorPoint = .zero
        repeat {
            self.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32((gameScene?.size.width)! - self.size.width))),
                                    y: (gameScene?.size.height)! * 1.25 - self.size.height)
        } while self.position.x < (character.position.x + character.size.width)
            && (self.position.x + self.size.width) > (character.position.x - character.size.width)
        
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
        if !canShoot || gameScene!.playerIsDead {return}
        
        let enemyBullet = SKBulletsNode(texture: gameScene?.bulletTexture)
        
        if self.texture == self.leftTexture {
            enemyBullet.shoot(from: self,
                              to: .left,
                              fromPercentOfWidth: 0.8,
                              fromPercentOfHeight: 0.35,
                              toArray: bulletsArray!,
                              inScene: self.gameScene!)
            
        } else if self.texture == self.rightTexture {
            enemyBullet.shoot(from: self,
                              to: .right,
                              fromPercentOfWidth: 0.8,
                              fromPercentOfHeight: 0.35,
                              toArray: bulletsArray!,
                              inScene: self.gameScene!)
        }
    }
    
    // Getting Shot
    func didGetShot() {
        if !hasLanded {return}
        if shot {return}
        
        shot = true
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
        self.parentArray!.array!.remove(at: parentArray!.array!.index(of: self)!)
        
        self.gameScene = nil
        self.leftTexture = nil
        self.rightTexture = nil
        
        self.parentArray = nil
        self.bulletsArray = nil
        
        self.removeAllChildren()
        self.removeAllActions()
        
        self.removeFromParent()
    }
    
    deinit {
        print("Deinitialized Enemy Cowboy at \(Date())")
    }
}

