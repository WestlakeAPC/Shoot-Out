//
//  GameViewController.swift
//  Shoot Out
//
//  Created by Joseph Jin on 7/21/17.
//  Copyright © 2017 Westlake APC. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import GCHelper

class GlobalMultiplayerGameViewController: MultiplayerGameViewController, GCHelperDelegate {
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            GCHelper.sharedInstance.findMatchWithMinPlayers(2, maxPlayers: 2, viewController: self, delegate: self)
        }
    }
    
    // Return to Menu
    @IBAction func exitView(_ sender: Any) {
        super.exitView(sender, completion: nil)
    }
    
    /// Method called when a match has been initiated.
    func matchStarted() {
        sendAssignmentNumber()
    }
    
    /// Method called when the match has ended.
    func matchEnded() {
        
    }
    
    /// Method called when the device received data about the match from another device in the match.
    func match(_ match: GKMatch, didReceiveData data: Data, fromPlayer: String) {
        didReceiveData(data)
    }
    
    // MARK: Send data to other player.
    override func sendData(_ data: Data) throws {
        try GCHelper.sharedInstance.match!.sendData(toAllPlayers: data, with: .reliable)
    }
    
    deinit {
        print("Deinitialized GlobalMultiplayerGameViewController")
    }
}
