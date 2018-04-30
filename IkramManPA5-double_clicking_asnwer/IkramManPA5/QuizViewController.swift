//
//  QuizViewController.swift
//  IkramManPA5
//
//  Created by Ikram Hamizi on 4/25/18.
//  Copyright © 2018 cstech. All rights reserved.
//

import UIKit
import CoreMotion
import MultipeerConnectivity

//1//. BUGS:
//1- didReceive: data function is entered, but data is not unarchived (ANSWER)

//2//. TODO:
//1- UPDATE SCORES
//2- Winners and losers notified.
//3- RESTART QUIZ (button is non functional)
//4- Create other json files

class QuizViewController: UIViewController, MCSessionDelegate {
    
    //1 - VARS
    //Vars received from SEGUE
    var isMultiplayer: Bool?
    var MCsession: MCSession?
    
    //Global VARS
    private var MAXTIMEQUESTION = 20
    
    private var TIMER = Timer()
    private var time = 6
    
    private var questions: [[String:Any]]!
    private var questions_size: Int!
    
    private var current_question: [String:Any]!
    private var c_q_index = 0
    private var currentQuestion_number = 1 //Also = c_q_index + 1
    
    private var correctOption: String!
    private var isCorrectAnswer = false
    private var isClicked = false
    
    private var chosenOption = 4
    private var submittedPlayersNUM = 0
    
    private var motionManager = CMMotionManager()
    
    /*
     private var selectedA = 0
     private var selectedB = 0
     private var selectedC = 0
     private var selectedD = 0
     */
    
    private var buttonList = [UIButton]()
    
    //IBOUTLETS
    @IBOutlet private weak var questionNUM: UILabel!
    
    @IBOutlet private weak var questionBody: UILabel!
    @IBOutlet private weak var optionA: UIButton!
    @IBOutlet private weak var optionB: UIButton!
    @IBOutlet private weak var optionC: UIButton!
    @IBOutlet private weak var optionD: UIButton!
    @IBOutlet private weak var timeLBL: UILabel!
    
    //MULTIPLAYER IMAGES
    @IBOutlet private weak var player1IMG: UIImageView!
    @IBOutlet private weak var player2IMG: UIImageView!
    @IBOutlet private weak var player3IMG: UIImageView!
    @IBOutlet private weak var player4IMG: UIImageView!
    
    @IBOutlet private weak var bubble1IMG: UIImageView!
    @IBOutlet private weak var bubble2IMG: UIImageView!
    @IBOutlet private weak var bubble3IMG: UIImageView!
    @IBOutlet private weak var bubble4IMG: UIImageView!
    
    private var multiplayerIMGS: [UIView]!
    private var ans1LBL: UILabel!
    private var ans2LBL: UILabel!
    private var ans3LBL: UILabel!
    private var ans4LBL: UILabel!
    
    @IBOutlet private weak var score1LBL: UILabel!
    @IBOutlet private weak var score2LBL: UILabel!
    @IBOutlet private weak var score3LBL: UILabel!
    @IBOutlet private weak var score4LBL: UILabel!
    
    private var score1 = 0
    private var score2 = 0
    private var score3 = 0
    private var score4 = 0
    
    @IBOutlet private weak var name1LBL: UILabel!
    @IBOutlet private weak var name2LBL: UILabel!
    @IBOutlet private weak var name3LBL: UILabel!
    @IBOutlet private weak var name4LBL: UILabel!
    
    
    //2- FUNCTIONS
    //1~ VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        multiplayerIMGS = [player1IMG, player2IMG, player3IMG, player4IMG, bubble1IMG, bubble2IMG, bubble3IMG, bubble4IMG, score1LBL, score2LBL, score3LBL, score4LBL, name1LBL, name2LBL, name3LBL, name4LBL]
        
        // Put the buttons in an array
        buttonList = [optionA, optionB, optionC, optionD]
        
        // Add action to each
        for each in buttonList {
            each.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        }
        
        unselectAllBTNs()
        
        if isMultiplayer!
        {
            unhideAllMultiplayerImages()
            addAnswerSubviewsToBubbles()
            multiplayer()
        }
        else
        {
            hideAllMultiplayerImages()
            singleplayer()
        }
        
        //Store questions.dict in a dictionary -> questions: [[String:Any]]!
        readQuestionsFromJSON()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        motionManager.deviceMotionUpdateInterval = 1/60
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateDeviceMotion), userInfo: nil, repeats: true)
    }
    
    // All buttons' alpha = 1
    private func unselectAllBTNs()
    {
        /*
         selectedA = 0
         selectedB = 0
         selectedC = 0
         selectedD = 0
         */
        
        for each in buttonList {
            each.alpha = 1
        }
    }
    
    private func addAnswerSubviewsToBubbles()
    {
        bubble1IMG.layer.zPosition = 1
        bubble2IMG.layer.zPosition = 1
        bubble3IMG.layer.zPosition = 1
        bubble4IMG.layer.zPosition = 1
        
        ans1LBL = UILabel()
        ans2LBL = UILabel()
        ans3LBL = UILabel()
        ans4LBL = UILabel()
        
        ans1LBL.text = "/"
        ans2LBL.text = "/"
        ans3LBL.text = "/"
        ans4LBL.text = "/"
        
        ans1LBL.layer.zPosition = 2
        ans2LBL.layer.zPosition = 2
        ans3LBL.layer.zPosition = 2
        ans4LBL.layer.zPosition = 2
        
        bubble1IMG.addSubview(ans1LBL)
        bubble2IMG.addSubview(ans2LBL)
        bubble3IMG.addSubview(ans3LBL)
        bubble4IMG.addSubview(ans4LBL)
    }
    
    private func hideAllMultiplayerImages()
    {
        for each in multiplayerIMGS {
            each.isHidden = true
        }
    }
    
    private func unhideAllMultiplayerImages()
    {
        //1. UNHIDE IMAGES
        for each in multiplayerIMGS {
            each.isHidden = false
        }
        
        if let peerCount = MCsession?.connectedPeers.count
        {
             //2. ALPHA = 1 only untill peerCount
            for i in stride(from: peerCount+1, to: multiplayerIMGS.count/4, by: 1)
            {
                multiplayerIMGS[i].alpha = 0.18
                multiplayerIMGS[i+4].alpha = 0.18
                multiplayerIMGS[i+2*4].alpha = 0.18
                multiplayerIMGS[i+3*4].alpha = 0.18
            }
  
            //3. Update names of players
            
            for i in stride(from: 0, to: peerCount, by: 1)
            {
                if let nameLBL = multiplayerIMGS[i+3*4] as? UILabel, let session = MCsession
                {
                    if i == 0
                    { nameLBL.text = "Me" }
                    else
                    { nameLBL.text = "\(session.connectedPeers[i].displayName)" }
                }
            }
        }
        //End of function
    }
    
    
    // Everytime a button is clicked, it sends the tag
    @IBAction func onClick(_ sender: UIButton) {
        
        unselectAllBTNs()
        // If the same button is clicked again, it sends the same tag as chosenOption
        // This will trigger submission
        if sender.tag == chosenOption {
            
            submitAnswer()
        }
            
            // The button is clicked for the first time, set the chosenOption to button's tag (id)
        else
        {
            chosenOption = sender.tag
            // Set chosen button's alpha to 0.5
            buttonList[chosenOption].alpha = 0.5
        }
    }
    
    //Chosen answer (BUTTON.TAG(chosenOption) -> STRING)
    private func chosenAnswer() -> String
    {
        var chosen: String
        switch chosenOption {
        case 0: chosen = "A"
        case 1: chosen = "B"
        case 2: chosen = "C"
        case 3: chosen = "D"
        default: chosen = ""
        }
        return chosen
    }
    
    // Submit the answer
    func submitAnswer() {
        
        //1. Submit answer single playar (after selection)
        let chosen = chosenAnswer()
        
        if chosen == correctOption {
            isCorrectAnswer = true
            timeLBL.text = "Correct! Answer is \(chosen)"
        }
        else {
            isCorrectAnswer = false
            timeLBL.text = "WRONG :( Answer is \(correctOption!)"
        }
        
        isClicked = true
        chosenOption = 4
        
         //2. (++) If multiplayer -> send answer to peers
        if isMultiplayer!
        {
            sendAnswerToPeers(score: chosen)
        }
    }
    
    private func sendAnswerToPeers(score: String)
    {
        let myAnswer =  NSKeyedArchiver.archivedData(withRootObject: score)
        
        do {
            try MCsession!.send(myAnswer, toPeers: MCsession!.connectedPeers, with: .reliable)
        }
        catch let e {
            print("Error in sending my score - \(e)")
        }
    }
    
    @objc func updateDeviceMotion(){
        
        if let data = motionManager.deviceMotion {
            
            let attitude = data.attitude
            
            let userAcceleration = data.userAcceleration
            
            print("accel x: \(userAcceleration.x),accel y: \(userAcceleration.y) ,accel z: \(userAcceleration.z)")
            // Tilted right, move chosen option to the right
            if attitude.roll > 0.8 && attitude.roll < 2 {
                
                if chosenOption == 0 || chosenOption == 2 {
                    chosenOption += 1
                    unselectAllBTNs()
                    buttonList[chosenOption].alpha = 0.5
                }
            }
            
            // Tilted left, move chosen option to the left
            if attitude.roll < -0.8  && attitude.roll > -2{
                
                if chosenOption == 1 || chosenOption == 3 {
                    chosenOption -= 1
                    unselectAllBTNs()
                    buttonList[chosenOption].alpha = 0.5
                }
            }
            
            // Tilted towards user, move option up
            if attitude.pitch > 1.5 {
                if chosenOption == 0 || chosenOption == 1 {
                    chosenOption += 2
                    unselectAllBTNs()
                    buttonList[chosenOption].alpha = 0.5
                }
            }
            // Tilted away from user, move option down
            if attitude.pitch < 0.3 {
                if chosenOption == 2 || chosenOption == 3 {
                    chosenOption -= 2
                    unselectAllBTNs()
                    buttonList[chosenOption].alpha = 0.5
                }
            }
            
            // If the device moves away from user at z acceleration greater than 0.5, or makes some big yaw > 3, submit the answer
            if userAcceleration.z < -0.5 || abs(attitude.yaw) > 3 {
                submitAnswer()
            }
            
        }
    }
    
    // Randomly select a button with a shake
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            var rand = Int(arc4random_uniform(4))
            
            // If the rand is the same as chosen option, get another one
            if rand == chosenOption {
                rand = Int(arc4random_uniform(4))
            }
            
            chosenOption = rand
            unselectAllBTNs()
            buttonList[chosenOption].alpha = 0.5
            
        }
    }
    /*
     @IBAction func onClickA(_ sender: UIButton)
     {
     selectedA += 1
     if selectedA == 1 // selected first time
     {
     unselectAllBTNs()
     selectedA = 1
     }
     else if selectedA == 2//A selected second time
     {
     unselectAllBTNs()
     isClicked = true
     
     if correctOption == "A"
     {
     isCorrectAnswer = true
     timeLBL.text = "Correct! Answer is A"
     }
     else
     {
     isCorrectAnswer = false
     timeLBL.text = "WRONG :( Answer is \(correctOption!)"
     }
     }
     }
     
     @IBAction func onClickB(_ sender: UIButton)
     {
     selectedB += 1
     if selectedB == 1 // selected first time
     {
     unselectAllBTNs()
     selectedB = 1
     }
     else if selectedB == 2
     {
     unselectAllBTNs()
     
     isClicked = true
     if correctOption == "B"
     {
     isCorrectAnswer = true
     timeLBL.text = "Correct! Answer is B"
     }
     else
     {
     isCorrectAnswer = false
     timeLBL.text = "WRONG :( Answer is \(correctOption!)"
     }
     }
     }
     @IBAction func onClickC(_ sender: UIButton)
     {
     selectedC += 1
     if selectedC == 1 // selected first time
     {
     unselectAllBTNs()
     selectedC = 1
     }
     else if selectedC == 2
     {
     unselectAllBTNs()
     isClicked = true
     
     if correctOption == "C"
     {
     isCorrectAnswer = true
     timeLBL.text = "Correct! Answer is C"
     }
     else
     {
     isCorrectAnswer = false
     timeLBL.text = "WRONG :( Answer is \(correctOption!)"
     }
     }
     }
     @IBAction func onClickD(_ sender: UIButton)
     {
     selectedD += 1
     if selectedD == 1// selected first time
     {
     unselectAllBTNs()
     selectedD = 1
     }
     else if selectedD == 2
     {
     unselectAllBTNs()
     isClicked = true
     if correctOption == "D"
     {
     isCorrectAnswer = true
     timeLBL.text = "Correct! Answer is D"
     }
     else
     {
     isCorrectAnswer = false
     timeLBL.text = "WRONG :( Answer is \(correctOption!)"
     }
     }
     }
     */
    
    private func multiplayer()
    {
        //1. Update the peer labels with their names
        if let session = MCsession
        {
            
        }
    }
    
    private func singleplayer()
    {
        
    }
    private func readQuestionsFromJSON()
    {
        //1- URL String
        let urlString = "http://www.people.vcu.edu/~ebulut/jsonFiles/quiz1.json"
        
        //2- Create URL
        let url = URL(string: urlString)
        
        //3- Create Session
        let session = URLSession.shared
        
        //4- Create a DATA TASK
        let datatask = session.dataTask(with: url!) { (data, response, error) in //(d,r,e) are optional
            if let result_from_url = data
            {
                //print ("READING JSON:")
                //print (result_from_url)
                
                do
                {
                    //Array (or catch error) of any object
                    let json = try JSONSerialization.jsonObject(with: result_from_url, options: .allowFragments) //as! AnyObject
                    
                    if let dict = json as? [String:Any] //1. Outer JSON DICT
                    {
                        if let questions = dict["questions"] as? [[String:Any]] //2. 1st Nested JSON DICT
                        {
                            //print ("I have questions")
                            self.questions = questions
                            //print ("COUNT: \(self.questions.count)")
                            
                            //Initialize variable
                            self.time = self.MAXTIMEQUESTION
                            self.questions_size = questions.count
                            self.current_question = questions[self.c_q_index] //question in questions-dict
                        }
                    }
                }
                catch
                {
                    print ("Error making Array froms JSON")
                }
            }
        }
        //5- LAUNCH
        datatask.resume()
        
        //6. Start displaying questions each 20 seconds (if option clicked, TIMER is invalidated).
        self.TIMER = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.start), userInfo: ["sth": self.current_question], repeats: true)
    }
    
    @objc func start(_ sender: Timer)
    {
        if let question = current_question
        {
            //1- Display question on screen
            if time == MAXTIMEQUESTION
            {
                //print ("MAX -> DISPLAY")
                displayOnScreenFromJSON(question)
            }
            
            time -= 1
            //print ("time--: \(time)")
            timeLBL.text = "time remaining: \(time)"
            
            //1- If Time is up --OR-- Singleplayer: option Clicked
            if time == 0 || (!isMultiplayer! && isClicked)
            {
                //2- Invalidate question TIMER
                invalidateTimer()
                
                //3- Start TIMER again
                nextQuestion()
            }
            
            //2- If Multiplayer: ** Wait until everyone has submitted -> nextQuestion()
            if isMultiplayer! && time > 0
            {
                if submittedPlayersNUM == MCsession!.connectedPeers.count
                {
                    nextQuestion()
                    submittedPlayersNUM = 0 //RESET
                }
            }
        }
    }
    
    //Helper functions:
    private func invalidateTimer()
    {
        //print ("invalidate\n\n")
        TIMER.invalidate()
    }
    
    private func nextQuestion()
    {
        isCorrectAnswer = false
        isClicked = false
        
        unselectAllBTNs()
        
        c_q_index += 1
        //print ("c_q_index = \(c_q_index)")
        time = MAXTIMEQUESTION
        
        if c_q_index < questions_size
        {
            self.current_question = questions[self.c_q_index]
            self.TIMER = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.start), userInfo: current_question, repeats: true)
        }
        else
        {
            timeLBL.text = "GAME OVER"
        }
    }
    
    //Helper func: Display on Options Button
    private func displayOnScreenFromJSON(_ question: [String : Any])
    {
        if let numberOfQuestion = question["number"] as? Int
        {
            //print ("Number of QQ = \(numberOfQuestion)")
            questionNUM.text = "Question \(numberOfQuestion)/4"
            //print ("\(question["questionSentence"] as! String)")
            self.questionBody.text = (question["questionSentence"] as! String) //1.Question
            if let options = question["options"] as? [String:Any] //4. 3rd Nested JSON Dict of each question in questions
            {
                self.optionA.setTitle((options["A"] as! String), for: .normal)
                self.optionB.setTitle((options["B"] as! String), for: .normal)
                self.optionC.setTitle((options["C"] as! String), for: .normal)
                self.optionD.setTitle((options["D"] as! String), for: .normal)
            }
            if let correctOption = question["correctOption"] as? String
            {
                self.correctOption = correctOption
            }
        }
    }
    
    //MARK - FNs: MCSessionDelegate (5 REQUIRED from class Protocol)
    //1. DID START RECEIVING
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //Called when a peer starts snding a "file" to this device
    }
    
    //2. DID RECEIVE
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //Called when a peer sends an "NSData" to this device
        
        print("QUIZ << didReceive data (ANS) START!")
        
        //1. Needs to be run on the main thread - Read data from peers
        DispatchQueue.main.async {
            if let receivedANS = NSKeyedUnarchiver.unarchiveObject(with: data) as? String
            {
                let peerIDindex = self.findCorrespondingPeerIndex(peerID: peerID)
                
                print ("QUIZ <<< I  RECEIVED from Player number: \(peerIDindex) - and their answer is: \(receivedANS)")
                
                //2. UPDATE LABELS (Answer + Score)
                self.updatePlayerLabels(peerIDindex: peerIDindex, receivedANS: receivedANS)
                
                //3. Update number of players who submitted an answer
                self.submittedPlayersNUM += 1
            }
            else
            {
                print ("<< :( could not receive data")
            }
        }
    }
    
    private func updatePlayerLabels(peerIDindex: Int, receivedANS: String)
    {
        switch peerIDindex {
        case 0:
            ans2LBL.text = receivedANS
            score2 += 1
            score2LBL.text = "\(score2)"
        case 1:
            ans3LBL.text = receivedANS
            score3 += 1
            score3LBL.text = "\(score3)"
        case 2:
            ans4LBL.text = receivedANS
            score4 += 1
            score4LBL.text = "\(score4)"
        default:
            break
        }
    }
    
    private func findCorrespondingPeerIndex(peerID: MCPeerID) -> Int
    {
        if let quizSession = MCsession
        {
            for i in stride(from: 0, to: quizSession.connectedPeers.count, by: 1)
            {
                if peerID.displayName == quizSession.connectedPeers[i].displayName
                {
                    return i
                }
            }
        }
        return -1
    }
    
    //3. DID RECEIVE STREAM
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        //Called when a peer establishes a stream with this device
    }
    
    //4. DID CHANGE
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        //Called when a connected peer changes states (e.g. goes offline)
        
        switch state {
        case MCSessionState.connected:
            print("Quiz - Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Quiz - Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Quiz - Disconnected: \(peerID.displayName)")
        }
    }
    
    //5. DIDFINISHRECEIVING
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)
    {
        //Called when a file has finished transferring from another peer
    }
}
