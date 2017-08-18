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

struct Properties: Codable {
    // SpriteKit physics bodies
    var ourCharacterPhysics: CGVector
    var ourCharacterPosition: CGPoint
    var ourCharacterDirection: Direction
    
    // Arrays
    var playerBulletArray: [BulletInformation] = []
    var enemyBulletArray: [BulletInformation] = []
}

struct BulletInformation: Codable {
    var position: CGPoint
    var direction: Direction
}

enum Direction: String, Codable {
    case left
    case right
}

// MARK: Codable extensions.

extension GameEvent: Codable {
    enum CodingKeys: CodingKey {
        case messageType
        case randomNumberValue
        case characterValue
        case properties
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch (try container.decode(String.self, forKey: .messageType)) {
            case "character_assignment":
                let value = try container.decode(Int.self, forKey: .randomNumberValue)
                self = .characterAssignment(randomNumber: value)
            case "shot":
                self = .shot
            case "died":
                self = .died
            case "restart":
                self = .restart
            case "terminated":
                self = .terminated
            case "property_update":
                let properties = try container.decode(Properties.self, forKey: .properties)
                self = .propertyUpdate(properties)
            default:
                throw DecodingError.typeMismatch(type(of: self), DecodingError.Context(codingPath: [],
                                                                                       debugDescription: "Invalid MessageType specified."))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch (self) {
            case .characterAssignment(let randomNumber):
                try container.encode("character_assignment", forKey: .messageType)
                try container.encode(randomNumber, forKey: .randomNumberValue)
            case .shot:
                try container.encode("shot", forKey: .messageType)
            case .died:
                try container.encode("died", forKey: .messageType)
            case .restart:
                try container.encode("restart", forKey: .messageType)
            case .terminated:
                try container.encode("terminated", forKey: .messageType)
            case .propertyUpdate(let properties):
                try container.encode("property_update", forKey: .messageType)
                try container.encode(properties, forKey: .properties)
        }
    }
}
