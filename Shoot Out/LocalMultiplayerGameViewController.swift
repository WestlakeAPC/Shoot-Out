//
//  LocalMultiplayerGameController.swift
//  
//
//  Created by Joseph Jin on 8/10/17.
//
//

import UIKit
import SpriteKit
import GameKit
import MultipeerConnectivity
import Toast_Swift

class LocalMultiplayerGameViewController: MultiplayerGameViewController, MCBrowserViewControllerDelegate {

    var appDelegate: AppDelegate!
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMPC()
    }
    
    // MARK: Setup MPC
    func setupMPC() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.adertiseSelf(advertise: true)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(peerChangedStateWithNotification(_:)),
                                               name: NSNotification.Name(rawValue: "MPC_DidChangeStateNotification"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleReceivedDataWithNotification(_:)),
                                               name: NSNotification.Name(rawValue: "MPC_DidReceiveDataNotification"),
                                               object: nil)
    }
    
    // MARK: Display connection ViewController
    @IBAction override func connectToPlayers(_ sender: Any) {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
            
            appDelegate.mpcHandler.browser.view.makeToast("Please keep devices close together for optimal connection.", duration: 3.0, position: .bottom)
        }
    }
    
    // MARK: Check peer connection
    @objc func peerChangedStateWithNotification(_ notification: NSNotification) {
        print("Changed State:")
        
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.object(forKey: "state")
        guard let sessionState = state as? MCSessionState else {
            return
        }
        
        switch (sessionState) {
            case .connected:
                print("Connected")
                sendAssignmentNumber()
                appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
            
            case .connecting:
                print("Connecting")
            
            case .notConnected:
                print("Disconnected")
        }
    }
    
    // MARK: Handle received data
    @objc func handleReceivedDataWithNotification(_ notification: NSNotification) {
        let userInfo = notification.userInfo! as Dictionary
        let receivedData: Data = userInfo["data"] as! Data
        
        didReceiveData(receivedData)
    }
    
    // MARK: Send data to other player.
    override func sendData(_ data: Data) throws {
        try appDelegate.mpcHandler.session.send(data, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: .reliable)
    }
    
    // MARK: Return to Menu
    @IBAction func exitView(_ sender: Any) {
        super.exitView(sender, completion: {
            self.appDelegate.mpcHandler.adertiseSelf(advertise: false)
            self.appDelegate.mpcHandler.session.disconnect()
            self.appDelegate.mpcHandler.session = nil
            self.appDelegate.mpcHandler.browser.delegate = nil
        })
    }
    
    // MARK: MCBrowserViewControllerDelegate conformance.
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("Deinitialized LocalMultiplayerGameViewController")
    }
}
