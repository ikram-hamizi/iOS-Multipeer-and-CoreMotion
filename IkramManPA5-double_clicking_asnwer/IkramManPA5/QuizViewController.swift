//
//  QuizViewController.swift
//  IkramManPA5
//
//  Created by Ikram Hamizi on 4/25/18.
//  Copyright © 2018 cstech. All rights reserved.
//

import UIKit
import CoreMotion

class QuizViewController: UIViewController {
    
    //1 - VARS
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
    
    var myScore = 0
    
    var chosenOption = 4
    
    var motionManager = CMMotionManager()

    var buttonList = [UIButton]()
    //IBOUTLETS
    @IBOutlet weak var questionNUM: UILabel!
    
    @IBOutlet weak var questionBody: UILabel!
    @IBOutlet weak var optionA: UIButton!
    @IBOutlet weak var optionB: UIButton!
    @IBOutlet weak var optionC: UIButton!
    @IBOutlet weak var optionD: UIButton!
    @IBOutlet weak var timeLBL: UILabel!
    
    @IBOutlet weak var myScoreLabel: UILabel!
    
    @IBOutlet weak var restartButton: UIButton!
    
    //2- FUNCTIONS
    //1~ VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Put the buttons in an array
        buttonList = [optionA, optionB, optionC, optionD]
        // Add action to each
        for each in buttonList {
            each.addTarget(self, action: #selector(onClick(_:)), for: .touchUpInside)
        }
        
        unselectAllBTNs()
        
        myScoreLabel.text = "My Score: \(myScore)"
        
        restartButton.isHidden = true
        
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
      
        for each in buttonList {
            each.alpha = 1
        }
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
        else {
        chosenOption = sender.tag
        // Set chosen button's alpha to 0.5
        buttonList[chosenOption].alpha = 0.5
        }
    }
    
    // Submit the answer
    func submitAnswer() {
        
        var chosen: String
        switch chosenOption {
        case 0: chosen = "A"
        case 1: chosen = "B"
        case 2: chosen = "C"
        case 3: chosen = "D"
        default: chosen = ""
        }
        
        if chosen == correctOption {
            isCorrectAnswer = true
            myScore += 1
            timeLBL.text = "Correct! Answer is \(chosen)"
        }
        else {
            isCorrectAnswer = false
            timeLBL.text = "WRONG :( Answer is \(correctOption!)"
        }
        
        myScoreLabel.text = "My Score: \(myScore)"
        isClicked = true

        chosenOption = 4
    }
    
    @objc func updateDeviceMotion(){
        
        if let data = motionManager.deviceMotion {
            
            let attitude = data.attitude
            
            let userAcceleration = data.userAcceleration

            // Tilt right, move chosen option to the right 0->1, 2->3
            if attitude.roll > 0.8 && attitude.roll < 2 {
                
                if chosenOption == 0 || chosenOption == 2 {
                    chosenOption += 1
                    unselectAllBTNs()
                    buttonList[chosenOption].alpha = 0.5
                }
            }
            
            // Tilt left, move chosen option to the left 1->0, 3->2
            if attitude.roll < -0.8  && attitude.roll > -2{
                
                if chosenOption == 1 || chosenOption == 3 {
                    chosenOption -= 1
                    unselectAllBTNs()
                    buttonList[chosenOption].alpha = 0.5
                }
            }
            
            // Tilt towards user, move option up 0->2, 1->3
            if attitude.pitch > 1.5 {
                if chosenOption == 0 || chosenOption == 1 {
                    chosenOption += 2
                    unselectAllBTNs()
                    buttonList[chosenOption].alpha = 0.5
                }
            }
            // Tilt away from user, move option down 2->0, 3->1
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
            
            if time == 0 || isClicked
            {
                //2- Invalidate question TIMER
                invalidateTimer()
                
                //3- Start TIMER again after 2s
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                    self.nextQuestion()
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
            restartButton.isHidden = false
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
    
    
    @IBAction func restartAction(_ sender: UIButton) {
        
        currentQuestion_number = 1
        c_q_index = 0
        chosenOption = 4
        isClicked = false
        isCorrectAnswer = false
        myScore = 0
        
        myScoreLabel.text = "My Score: \(myScore)"
        
        restartButton.isHidden = true
        
        readQuestionsFromJSON()
    }
    
   
}
