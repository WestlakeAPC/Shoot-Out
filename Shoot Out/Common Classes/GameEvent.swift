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
    case characterAssignment(randomNumber: Int)
    case shot
    case died
    case restart
    case terminated
    case propertyUpdate(Properties)
}

struct Properties {
    // SpriteKit physics bodies
    var ourCharacterPhysics: CGVector
    var ourCharacterPosition: CGPoint
    var ourCharacterDirection: Direction
    
    // Arrays
    var playerBulletArray: [BulletInformation] = []
    var enemyBulletArray: [BulletInformation] = []
}

struct BulletInformation {
    var position: CGPoint
    var direction: Direction
}

enum Direction: String {
    case left
    case right
}

// MARK: NSCoding wrapper classes.

class EncodableGameEvent: NSCoding {
    let gameEvent: GameEvent
    
    init(_ gameEvent: GameEvent) {
        self.gameEvent = gameEvent
    }
    
    func encode(with coder: NSCoder) {
        switch (gameEvent) {
            case .characterAssignment(let randomNumber):
                coder.encode("character_assignment", forKey: "message_type")
                coder.encode(randomNumber, forKey: "random_number_value")
            case .shot:
                coder.encode("shot", forKey: "message_type")
            case .died:
                coder.encode("died", forKey: "message_type")
            case .restart:
                coder.encode("restart", forKey: "message_type")
            case .terminated:
                coder.encode("terminated", forKey: "message_type")
            case .propertyUpdate(let properties):
                coder.encode("property_update", forKey: "message_type")
                coder.encode(EncodableProperties(properties), forKey: "properties")
        }
    }
    
    required init?(coder: NSCoder) {
        switch (coder.decodeObject(forKey: "message_type") as! String) {
            case "character_assignment":
                let value = coder.decodeInteger(forKey: "random_number_value")
                gameEvent = .characterAssignment(randomNumber: value)
            case "shot":
                gameEvent = .shot
            case "died":
                gameEvent = .died
            case "restart":
                gameEvent = .restart
            case "terminated":
                gameEvent = .terminated
            case "property_update":
                let properties = coder.decodeObject(forKey: "properties") as! EncodableProperties
                gameEvent = .propertyUpdate(properties.properties)
            default:
                gameEvent = .died // I don't know why, this shouldn't happen anyways
        }
    }
}

class EncodableProperties: NSCoding {
    let properties: Properties
    
    init(_ properties: Properties) {
        self.properties = properties
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(properties.ourCharacterPhysics, forKey: "physics")
        coder.encode(properties.ourCharacterPosition, forKey: "position")
        coder.encode(properties.ourCharacterDirection.rawValue, forKey: "direction")
        
        let playerBulletArray = properties.playerBulletArray.map { EncodableBulletInformation($0) }
        let enemyBulletArray = properties.enemyBulletArray.map { EncodableBulletInformation($0) }
        
        coder.encode(playerBulletArray, forKey: "player_bullets")
        coder.encode(enemyBulletArray, forKey: "enemy_bullets")
    }
    
    required init?(coder: NSCoder) {
        let ourCharacterPhysics = coder.decodeCGVector(forKey: "physics")
        let ourCharacterPosition = coder.decodeCGPoint(forKey: "position")
        let ourCharacterDirection = Direction(rawValue: coder.decodeObject(forKey: "direction") as! String)!
        
        let playerBulletArray = (coder.decodeObject(forKey: "player_bullets") as! [EncodableBulletInformation]).map { $0.bulletInformation }
        let enemyBulletArray = (coder.decodeObject(forKey: "enemy_bullets") as! [EncodableBulletInformation]).map { $0.bulletInformation }
        
        properties = Properties(ourCharacterPhysics: ourCharacterPhysics,
                                ourCharacterPosition: ourCharacterPosition,
                                ourCharacterDirection: ourCharacterDirection,
                                playerBulletArray: playerBulletArray,
                                enemyBulletArray: enemyBulletArray)
    }
}

class EncodableBulletInformation: NSCoding {
    let bulletInformation: BulletInformation
    
    init(_ bulletInformation: BulletInformation) {
        self.bulletInformation = bulletInformation
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(bulletInformation.position, forKey: "position")
        coder.encode(bulletInformation.direction.rawValue, forKey: "direction")
    }
    
    required init?(coder: NSCoder) {
        let position = coder.decodeCGPoint(forKey: "position")
        let direction = Direction(rawValue: coder.decodeObject(forKey: "direction") as! String)!
        
        bulletInformation = BulletInformation(position: position, direction: direction)
    }
}
