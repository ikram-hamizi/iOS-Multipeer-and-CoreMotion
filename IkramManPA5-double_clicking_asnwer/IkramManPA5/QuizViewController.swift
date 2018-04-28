//
//  QuizViewController.swift
//  IkramManPA5
//
//  Created by Ikram Hamizi on 4/25/18.
//  Copyright © 2018 cstech. All rights reserved.
//

import UIKit
//1- BUGS:
//1. Tap twice on selected answer (not bug, but needs to be changed)

//2- TODO:
//1. Change color when answer is selected
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
    
    
    private var selectedA = 0
    private var selectedB = 0
    private var selectedC = 0
    private var selectedD = 0
    
    
    //IBOUTLETS
    @IBOutlet weak var questionNUM: UILabel!
    
    @IBOutlet weak var questionBody: UILabel!
    @IBOutlet weak var optionA: UIButton!
    @IBOutlet weak var optionB: UIButton!
    @IBOutlet weak var optionC: UIButton!
    @IBOutlet weak var optionD: UIButton!
    @IBOutlet weak var timeLBL: UILabel!
    
    //2- FUNCTIONS
    //1~ VIEWDIDLOAD
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        unselectAllBTNs()
        
        //Store questions.dict in a dictionary -> questions: [[String:Any]]!
        readQuestionsFromJSON()
    }
    
    private func unselectAllBTNs()
    {
        selectedA = 0
        selectedB = 0
        selectedC = 0
        selectedD = 0
    }

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
                print ("READING JSON:")
                print (result_from_url)
                
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
        
        
        //6. Start displaying questions each 20 minutes (if option clicked, TIMER is invalidated).
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
                
                //3- Start TIMER again
                nextQuestion()
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
}
