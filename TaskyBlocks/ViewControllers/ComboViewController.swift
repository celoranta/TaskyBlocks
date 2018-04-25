//
//  ComboViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-24.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import AppusCircleTimer

enum TimerState
{
  case setup, pause, run
}

enum EstimateState
{
  case over, under
}

class ComboViewController: UIViewController, AppusCircleTimerDelegate {
  
  
  
  //MARK: Outlets
  
  @IBOutlet weak var topLabelOutlet: UILabel!
  @IBOutlet weak var tasksWordOutlet: UILabel!
  @IBOutlet weak var completeWordOutlet: UILabel!
  @IBOutlet weak var wonCountOutlet: UILabel!
  @IBOutlet weak var timerLeftLabel: UILabel!
  @IBOutlet weak var timerRightLabel: UILabel!
  @IBOutlet weak var taskTitleLabel: UILabel!
  @IBOutlet weak var taskDescriptionLabel: UILabel!
  @IBOutlet weak var stepperOutlet: UIStepper!
  
  @IBOutlet weak var mainTimerOutlet: AppusCircleTimer!
  @IBOutlet weak var leftTimerOutlet: AppusCircleTimer!
  @IBOutlet weak var rightTimerOutlet: AppusCircleTimer!
  
  var selectedTask: TaskyNode? = TaskyNodeEditor.sharedInstance.database[0]
  var timerState: TimerState = .setup
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mainTimerOutlet.delegate = self
    leftTimerOutlet.delegate = self
    rightTimerOutlet.delegate = self
    
    mainTimerOutlet.isBackwards = true
    mainTimerOutlet.totalTime = 600
    mainTimerOutlet.pauseColor = UIColor.green
    mainTimerOutlet.activeColor = UIColor.yellow
    mainTimerOutlet.start()
    mainTimerOutlet.stop()
    mainTimerOutlet.reset()
    
    leftTimerOutlet.isBackwards = true
    
    
    stepperOutlet.stepValue = 5.0
    stepperOutlet.minimumValue = 10
    stepperOutlet.maximumValue = 90
    
    drawScreen()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  fileprivate func drawScreen()
  {
    if let uTask = selectedTask
    {
      taskTitleLabel.text = uTask.title
    }
    
    switch self.timerState
    {
    case .setup:
      self.topLabelOutlet.text = "Configure Your Session"
      self.tasksWordOutlet.isHidden = true
      self.completeWordOutlet.isHidden = true
      self.wonCountOutlet.isHidden = true
      self.stepperOutlet.isHidden = false
      mainTimerOutlet.start()
      mainTimerOutlet.stop()
      mainTimerOutlet.reset()
    case .pause:
      self.topLabelOutlet.text = "Session Paused"
      self.tasksWordOutlet.isHidden = false
      self.completeWordOutlet.isHidden = false
      self.wonCountOutlet.isHidden = false
      self.stepperOutlet.isHidden = true
      self.mainTimerOutlet.stop()
    case .run:
      self.topLabelOutlet.text = "Complete your Tasks"
      self.tasksWordOutlet.isHidden = false
      self.completeWordOutlet.isHidden = false
      self.wonCountOutlet.isHidden = false
      self.stepperOutlet.isHidden = true
      self.mainTimerOutlet.start()
    }
    if let uSelectedTask = selectedTask
    {
      let settings = calculateTimerSettings(for: uSelectedTask)
      setupLeftTimer(state: settings.0, total: settings.1, advanced: Double(settings.2))
      self.view.layoutSubviews()
    }
  }
    
    
    func circleCounterTimeDidExpire(circleTimer: AppusCircleTimer) {
      switch circleTimer.accessibilityIdentifier {
      case "mainTimer":
        print("Main timer expired")
      case "leftTimer":
        print("Left timer expired")
        
      case  "rightTimer":
        print("Right timer expired")
      default:
        fatalError("Delegate method called by non-existant timer")
      }
    }
    
    private func calculateTimerSettings(for task: TaskyNode) -> (state: EstimateState, total: Double, advanced: Int)
    {
      var state: EstimateState
      var total: Double
      var advanced: Int
      if let uEstimate = task.secondsEstimated.value
      {
        if uEstimate <= task.secondsElapsed
        {
          state = .under
        }
        else
        {
          state = .over
        }
        switch state
        {
        case .under:
          total = Double(uEstimate)
          advanced = task.secondsElapsed
        case .over:
          if Double(task.secondsElapsed) >= 1.75 * Double(uEstimate)
          {
            total = Double(task.secondsElapsed) * 1.75
            advanced = task.secondsElapsed - uEstimate
          }
          else
          {
            total = Double(task.secondsElapsed) * 2.0
            advanced = task.secondsElapsed - uEstimate
          }
        }
      }
      else
      {
        state = .under
        total = 0
        advanced = 0
      }
      return (state, total, advanced)
    }
    
    private func setupLeftTimer(state: EstimateState, total: Double, advanced: Double)
    {
      switch state
      {
      case .under:
        self.leftTimerOutlet.pauseColor = UIColor.green
      case.over:
        self.leftTimerOutlet.pauseColor = UIColor.red
      }
      self.leftTimerOutlet.totalTime = Double(total)
      self.leftTimerOutlet.elapsedTime = Double(advanced)
      self.leftTimerOutlet.start()
      self.leftTimerOutlet.stop()
    }
    
    //MARK: Actions
    
    @IBAction func timeStepper(_ sender: Any) {
      let duration = stepperOutlet.value
      mainTimerOutlet.totalTime = duration * 60
      mainTimerOutlet.start()
      mainTimerOutlet.stop()
      mainTimerOutlet.reset()
      print(duration)
      
    }
    @IBAction func completionBoxButton(_ sender: Any) {
    }
    @IBAction func chooseTaskButton(_ sender: Any) {
    }
    @IBAction func mainTimerTap(_ sender: Any) {
      switch self.timerState
      {
      case .setup:
        self.timerState = .run
      case .run:
        self.timerState = .pause
      case .pause:
        self.timerState = .run
      }
      drawScreen()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
