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
    enum Character: Int {
        case main = 0
        case other
    }
    
    case characterAssignment(Int)
    case shot
    case gameOver(playerWon: Character)
    case hit(player: Character)
    case restart
    case terminated
    case propertyUpdate(Properties)
}

struct Properties {
    // SpriteKit physics bodies
    var ourCharacterPhysics: SKPhysicsBody
    
    // Arrays
    var playerBulletArray: [SKPhysicsBody] = []
    var enemyBulletArray: [SKPhysicsBody] = []
}
