//
//  SKPlayerNode.swift
//  Shoot Out
//
//  Created by Joseph Jin on 8/16/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import Foundation
import SpriteKit

class SKPlayerNode: SKSpriteNode {
    
    enum direction {
        case left
        case right
    }
    
    var facingDirection: direction = .left
    var textures: Dictionary<direction, SKTexture>?
    
    func assignTextures(left lTexture: SKTexture, right rTexture: SKTexture) {
        self.textures = [.left: lTexture, .right: rTexture]
    }
    
}
