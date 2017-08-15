//
//  Event.swift
//  Shoot Out
//
//  Created by Eli Bradley on 8/14/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import Foundation
import SpriteKit

enum GameEvent {
    case characterAssignment(Int)
    case shot
    case gameOver(player0Won: Bool)
    case restart
    case terminated
    case propertyUpdate(Properties)
}

struct Properties {
    // SpriteKit physics bodies
    var alphaCharacterPhysics: SKPhysicsBody
    var betaCharacterPhysics: SKPhysicsBody
    var mainCharacterPhysics: SKPhysicsBody
    var opposingCharacterPhysics: SKPhysicsBody
    
    // Score
    var aliensKilled = 0
    var score = 0
    
    // Arrays
    var playerBulletArray: [SKPhysicsBody] = []
    var enemyBulletArray: [SKPhysicsBody] = []
}
