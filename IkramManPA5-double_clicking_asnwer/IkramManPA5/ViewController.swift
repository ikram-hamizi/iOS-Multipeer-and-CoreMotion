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
    
    private var MAXPLAYERS = 1
    private var players_peerIDs: [MCPeerID]!
    
    private var gameIsChosen = false
     private var isMultiPlayer = false
    
    //I- FUNCTIONS
    override func viewDidLoad()
    {
        super.viewDidLoad()
        gameIsChosen = false
        players_peerIDs = [MCPeerID]()
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
    
    private func sendInformation()
    {
        let dataToSend =  NSKeyedArchiver.archivedData(withRootObject: players_peerIDs)
        
        do{
            try session.send(dataToSend, toPeers: session.connectedPeers, with: .unreliable)
        }
        catch let e {
            print("Error in sending data \(e)")
        }
    }
    
    private func singleplayer()
    {
        
    }
    
    @IBAction func chooseGame(_ sender: UISegmentedControl)
    {
        if (sender.selectedSegmentIndex == 0) //SINGLE PLAYER
        {
            print ("SINGLE")
            singleplayer()
            isMultiPlayer = false
            gameIsChosen = true
        }
        else //MULTI PLAYER
        {
            print ("MULTI")
            multiplayer()
            gameIsChosen = true
            isMultiPlayer = true
        }
    }
   
    
    @IBAction func startQuiz(_ sender: UIButton)
    {
        print ("start quiz clicked")
        if gameIsChosen
        {
            print ("game chosen -> quiz can start")
            performSegue(withIdentifier: "startQuizSegue", sender: sender)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let quizSegue = segue.destination as? QuizViewController
        {
            quizSegue.isMultiplayer = isMultiPlayer
            quizSegue.MCsession = session
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
    
    //DID START RECEIVING
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //Called when a peer starts snding a "file" to this device
    }
    
    //DID RECEIVE
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //Called when a peer sends an "NSData" to this device
        
        print("<< didReceive data START!")
        
        //Needs to be run on the main thread
        DispatchQueue.main.async {
            if let receivedPEERS = NSKeyedUnarchiver.unarchiveObject(with: data) as? [MCPeerID]
            {
                print ("<<< I  RECEIVED NEW PEER ADDED: \([receivedPEERS.count])")
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
        //Called when a connected peer changes states (e.g. goes offline)
        
        switch state {
        case MCSessionState.connected:
            if MAXPLAYERS > 0
            {
                print("Connected: \(peerID.displayName)")
                //sendInformation()
                MAXPLAYERS -= 1
            }
            if MAXPLAYERS == 0
            {
                ADassistant.stop() //1. Stop advertising
                browserViewControllerDidFinish(browser) //2. Exit "Done" MP Browser
                MAXPLAYERS -= 1 //3. Prevent from entering the condition-statements.
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Disconnected: \(peerID.displayName)")
        }
    }
    
    //DIDFINISHRECEIVING
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //Called when a file has finished transferring from another peer
    }
}

//1- Icon made by freepik https://www.flaticon.com/authors/freepik
//2- Icon made by prosymbols https://www.flaticon.com/authors/prosymbols
