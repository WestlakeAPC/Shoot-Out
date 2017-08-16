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
    weak var gameScene: MultiplayerScene?
    
    var appDelegate: AppDelegate!
    
    var characterAssignmentNumber: Int = 0
    var receivedAssignmentNumber: Int = 0
    
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var jumpButton: UIButton!
    @IBOutlet var shootButton: UIButton!
    
    @IBOutlet var skView: SKView!
    
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
        
        scene?.scaleMode = .aspectFit
        
        // Present current scene
        skView!.presentScene(scene)
        skView?.allowsTransparency = true
        skView?.backgroundColor = .clear
        
        self.gameScene = scene as! MultiplayerScene?
        self.gameScene?.viewController = self
        
        skView!.ignoresSiblingOrder = true
        skView?.showsFPS = true
        skView?.showsNodeCount = true
        skView?.showsPhysics = true
    }
    
    // TODO: Continue method call as long as button is held
    func longPressGesture() {
        
        let leftButtonLPG = UITapGestureRecognizer(target: self, action: #selector(moveLeft))
        leftButton.addGestureRecognizer(leftButtonLPG)
        
        let rightButtonLPG = UITapGestureRecognizer(target: self, action: #selector(moveRight))
        rightButton.addGestureRecognizer(rightButtonLPG)
        
        let jumpButtonLPG = UITapGestureRecognizer(target: self, action: #selector(jump))
        jumpButton.addGestureRecognizer(jumpButtonLPG)
        
        let shootButtonLPG = UITapGestureRecognizer(target: self, action: #selector(shoot))
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
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(connectToPlayers), userInfo: nil, repeats: false)
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
                sendAssignmentNumber()
            
            case .connecting:
                print("Connecting")
            
            case .notConnected:
                print("Disconnected")
            
        }
    }
    
    // MARK: Handle received data
    func handleReceivedDataWithNotification(_ notification: NSNotification) {
        let userInfo = notification.userInfo! as Dictionary
        let receivedData: Data = userInfo["data"] as! Data
        
        do {
            // Obtain Dictionary Sent Out By Other Players
            let message = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            let Event = message["Event"] as! String
            print("Received Event: \n\(String(describing: Event))")
            
            // Interpret and Process Received Information
            switch Event {
            case "characterAssignment":
                self.receivedAssignmentNumber = message["Event Value"] as! Int
                gameScene?.assignCharacters(localValue: self.characterAssignmentNumber, remoteValue: self.receivedAssignmentNumber)
                
            default:
                print("Received Other Event Options")
            }
            
        } catch {
            print("R.I.P. When receiving data, you encountered: " + error.localizedDescription)
        }
    }
    
    // Connect
    @IBAction func connectWithPlayers(_ sender: Any) {
        self.connectToPlayers()
    }
    
    // MARK: Send Data to Other Players
    func sendData(OfInformation messageDict: Dictionary<String, Any>) {
        //print("Sending Message: \(messageDict)")
        
        do {
            let messageData = try JSONSerialization.data(withJSONObject: messageDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: .reliable)
            
        } catch {
            print("R.I.P. When sending data, you encountered: " + error.localizedDescription)
        }
    }
    
    
    // Character Assignment
    func sendAssignmentNumber() {
        // Send Random Number Message
        self.characterAssignmentNumber = Int(arc4random_uniform(UInt32(99999999)))
        
        let messageDict = ["Event": "characterAssignment", "Event Value": self.characterAssignmentNumber] as [String : Any]
        
        sendData(OfInformation: messageDict)
    }
    
    // Sending Character State
    func sendCharacterState(physicsOf physics: SKPhysicsBody, positionOf position: CGPoint, directionOf direction: String) {
        
        let properties = ["Physics": physics, "Position": position, "Direction": direction] as [String : Any]
        let messageDict = ["Event": "propertyUpdate", "Event Value": properties] as [String : Any]
        
        sendData(OfInformation: messageDict)
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
        print("Deinitialized LocalMultiplayerGameViewController")
    }

}
