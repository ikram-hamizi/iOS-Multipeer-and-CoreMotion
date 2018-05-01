//
//  ViewController.swift
//  IkramManPA5
//
//  Created by cstech on 03/25/18.
//  Copyright © 2018 Ikram Hamizi. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    //1- VARS
    private var peerID: MCPeerID! //1.
    private var session: MCSession! //2.
    private var browser: MCBrowserViewController! //3.
    private var ADassistant: MCAdvertiserAssistant! //4.
    
    private var MAXPLAYERS = 4
    
    // Game type 0 for single, 1 for multiplayer
    var gameType = 0
    
    //I- FUNCTIONS
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView.init(image: UIImage(named: "title"))
    }
    
    private func multiplayer()
    {
        let serviceType = "Chat"
        
        //1. peerID: Device with property displayName
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        
        //2. Session: Connection between devices
        self.session = MCSession(peer: peerID)
        
        //3. Browser: Used to find nearby devices and invite them to a session
        self.browser = MCBrowserViewController(serviceType: serviceType, session: session)
        
        //4. Assistant: Advertise the device and make it visible to others
        self.ADassistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        
        //5. Start
        ADassistant.start()
        
        session.delegate = self
        browser.delegate = self
        
        //--> PRESENT --- (3.Browser)
        present(browser, animated: true, completion: nil)
    }
 
    
    @IBAction func chooseGame(_ sender: UISegmentedControl)
    {
        if (sender.selectedSegmentIndex == 0) //SINGLE PLAYER
        {
            print ("SINGLE")
            gameType = 0
        }
        else //MULTI PLAYER
        {
            print ("MULTI")
            multiplayer()
            gameType = 1
        }
    }
    
    
    @IBAction func startQuiz(_ sender: UIButton)
    {
            // gameType = 0, go to singlePlayer VC
            if gameType == 0 {
                performSegue(withIdentifier: "singlePlayer", sender: self)
            }
            
            else {
                if self.session.connectedPeers.count == 0 {
                    
                    let alert = UIAlertController(title: "Error", message: "No connected players", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alert.addAction(cancelAction)
                    
                    present(alert, animated: true, completion: nil)
                    
                }
                
                else {
                    
                    do {
                        let data = NSKeyedArchiver.archivedData(withRootObject: "Start")
                        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                    }
                    catch let err{
                        print(err)
                    }
                    
                    performSegue(withIdentifier: "multiplayer", sender: self)
                    
                }
            }
            
        
    }
    
    //II. Mandatory FNs
    //1. MCBrowserViewControllerDelegate (2 REQUIRED)
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        //When MCBrowserViewController is dismissed
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        //When MCBrowserViewController is cancelled
        dismiss(animated: true, completion: nil)
    }
    
    //2. MCSessionDelegate (5 REQUIRED)
    
    //DID RECEIVE
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //Called when a peer starts snding a "file" to this device
    }
    
    //DID RECEIVE
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //Called when a peer sends an "NSData" to this device
        
        
        //Needs to be run on the main thread
        DispatchQueue.main.async {
            if let received = NSKeyedUnarchiver.unarchiveObject(with: data) as? String
            {
                if received == "Start" {
                    self.performSegue(withIdentifier: "multiplayer", sender: self)
                }
            }
        }
    }
    
    //DID RECEIVE STREAM
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //Called when a peer establishes a stream with this device
    }
    
    //DID CHANGE
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        // Do the player count check everytime someone tries to connect
        if state == .connecting {
            // Check if maximum number of players has reached
            if session.connectedPeers.count == MAXPLAYERS {
                // Drop that guy, reject his connection
                session.cancelConnectPeer(peerID)
                // Close browser
                browser.dismiss(animated: true) {
                    // Show alert to user
                    let alert = UIAlertController(title: "Error", message: "Maximum number of users reached", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //DIDFINISHRECEIVING
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //Called when a file has finished transferring from another peer
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "multiplayer" {
            if let mvc = segue.destination as? multiplayerVC {
                mvc.peerID = self.peerID
                mvc.session = self.session
            }
        }
    }
}

//1- Icon made by freepik https://www.flaticon.com/authors/freepik
//2- Icon made by prosymbols https://www.flaticon.com/authors/prosymbols
