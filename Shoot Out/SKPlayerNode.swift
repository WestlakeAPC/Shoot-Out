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
    
    var facingDirection: Direction = .left
    var textures: Dictionary<Direction, SKTexture>?
    
    func assignTextures(left lTexture: SKTexture, right rTexture: SKTexture) {
        self.textures = [.left: lTexture, .right: rTexture]
    }
    
    func updateTexture() {
        self.texture = textures?[facingDirection]
    }
    
}
