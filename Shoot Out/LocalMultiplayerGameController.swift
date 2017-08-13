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

class LocalMultiplayerGameController: UIViewController, MCBrowserViewControllerDelegate {

    weak var scene: SKScene?
    weak var skView : SKView?
    weak var gameScene: MultiplayerScene?
    
    var appDelegate: AppDelegate!
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var jumpButton: UIButton!
    @IBOutlet var shootButton: UIButton!
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameScene()
        longPressGesture()
        setupMPC()
    }
    
    // MARK: Load Game Scene
    func loadGameScene() {
        // Create GameScene object
        scene = MultiplayerScene(fileNamed:"MultiplayerScene")
        
        // Make game display on different devices
        if (UIDevice.current.model == "iPhone"){
            print("Displaying on Device: iPhone")
            scene?.scaleMode = .aspectFill
            
        } else if (UIDevice.current.model == "iPad"){
            print("Displaying on Device: iPad")
            scene?.scaleMode = .aspectFit
            
        } else {
            print("Displaying on Device: Other Device")
            scene?.scaleMode = .aspectFill
            
        }
        
        // Present current scene
        skView = (self.view as! SKView)
        skView!.presentScene(scene)
        
        self.gameScene = scene as! MultiplayerScene?
        self.gameScene?.viewController = self
        
        skView!.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
        skView?.showsPhysics = false
        
        
    }
    
    // TODO: Continue method call as long as button is held
    func longPressGesture() {
        
        let leftButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.moveLeft))
        leftButton.addGestureRecognizer(leftButtonLPG)
        
        let rightButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.moveRight))
        rightButton.addGestureRecognizer(rightButtonLPG)
        
        let jumpButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.jump))
        jumpButton.addGestureRecognizer(jumpButtonLPG)
        
        let shootButtonLPG = UITapGestureRecognizer(target: self, action: #selector(self.shoot))
        shootButton.addGestureRecognizer(shootButtonLPG)
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
    func connectToPlayers() {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    // MARK: Check peer connection
    func peerChangedStateWithNotification(_ notification: NSNotification) {
        print("Changed State:")
        
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let state = userInfo.object(forKey: "state") as! Int
        guard let sessionState = MCSessionState(rawValue: state) else {
            return
        }
        
        switch (sessionState) {
        case .connected:
            print("Connected")
        case .connecting:
            print("Connecting")
        case .notConnected:
            print("Disconnected")
        }
    }
    
    // MARK: Handle received data
    func handleReceivedDataWithNotification(_ notification: NSNotification) {
        let userInfo = notification.userInfo!  as Dictionary
        let receivedData: NSData = userInfo["data"] as! NSData
        
        do {
            let message = try JSONSerialization.jsonObject(with: receivedData as Data, options: .allowFragments) as! NSDictionary
            print("Received:")
            print(message)
            
        } catch {
            print("R.I.P. When receiving data, you encountered: " + error.localizedDescription)
        }
    }
    
    // Connect
    @IBAction func connectWithPlayers(_ sender: Any) {
        self.connectToPlayers()
    }
    
    // Return to Menu
    @IBAction func exitView(_ sender: Any) {
        print("\nAttempting to deallocate \(String(describing: self.skView?.scene))\n")
        self.gameScene?.endAll()
        self.scene = nil
        self.gameScene?.viewController = nil
        self.gameScene = nil
        self.skView = nil
        self.skView?.presentScene(nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // TODO: Replace method calls eventually
    func moveLeft() {
        self.gameScene?.moveLeft()
    }
    
    func moveRight() {
        self.gameScene?.moveRight()
    }
    
    func jump() {
        self.gameScene?.jump()
    }
    
    func shoot() {
        self.gameScene?.shoot()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: Delegate Protocal Methods
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("Deinit LocalMultiplayerGameViewController.swift")
    }

}
