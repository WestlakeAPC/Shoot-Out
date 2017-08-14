//
//  MultiplayerGameHandlerDelegate.swift
//  Shoot Out
//
//  Created by Joseph Jin on 8/13/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import Foundation

protocol MultiplayerGameHandlerDelegate {
    func assignPlayers() -> String
    func updateOpposingCharacter()
    
    func gameDidStart()
    func gameDidEnd()
    func gameTerminated()
}
