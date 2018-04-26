//
//  ComboViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-24.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import AppusCircleTimer
import RealmSwift


enum TimerState
{
  case setup, pause, run, inactive
}

class ComboViewController: UIViewController, AppusCircleTimerDelegate, ChooseTask {

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
  @IBOutlet weak var doneSwitchOutlet: UISwitch!
  
  @IBOutlet weak var mainTimerOutlet: AppusCircleTimer!
  @IBOutlet weak var leftTimerOutlet: AppusCircleTimer!
  @IBOutlet weak var rightTimerOutlet: AppusCircleTimer!
  
  var selectedTask: TaskyNode? = nil//TaskyNodeEditor.sharedInstance.database[0]
  var timerState: TimerState = .setup
  var selectedTaskStart: Date!
  var loggedTaskTime: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mainTimerOutlet.delegate = self
    leftTimerOutlet.delegate = self
    rightTimerOutlet.delegate = self
    
    mainTimerOutlet.isBackwards = true
    mainTimerOutlet.pauseColor = UIColor.green
    mainTimerOutlet.activeColor = UIColor.yellow
    
    let userSettings = UserDefaults()
    stepperOutlet.value = userSettings.double(forKey: "DefaultSprintDuration")
    stepperOutlet.stepValue = 5.0
    stepperOutlet.minimumValue = 10
    stepperOutlet.maximumValue = 90
    
    mainTimerOutlet.totalTime = stepperOutlet.value
    mainTimerOutlet.start()
    mainTimerOutlet.stop()
    mainTimerOutlet.reset()
    
    drawScreen()
  }
  
  fileprivate func activeTimerConfig(with task: TaskyNode) {
    wakeUp(timer: mainTimerOutlet)
    wakeUp(timer: leftTimerOutlet)
    wakeUp(timer: rightTimerOutlet)
    taskTitleLabel.text = task.title
    taskDescriptionLabel.text = task.taskDescription
    self.doneSwitchOutlet.isOn = (task.completionDate != nil)
    setupLeftTimer(with: task)
  }
  
  fileprivate func drawScreen()
  {
    if let uSelectedTask = selectedTask
    {
      print("configuring timers with selected task '\(uSelectedTask)'")
      activeTimerConfig(with: uSelectedTask)
    }
    else
    {
      self.timerState = .inactive
    }
    switch self.timerState
    {
    case .setup:
      wakeUp(timer: mainTimerOutlet)
      self.topLabelOutlet.text = "Configure Your Session"
      self.tasksWordOutlet.isHidden = true
      self.completeWordOutlet.isHidden = true
      self.wonCountOutlet.isHidden = true
      self.stepperOutlet.isHidden = false
      mainTimerOutlet.totalTime = stepperOutlet.value * 60
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
      self.leftTimerOutlet.stop()
//put call to update logged task time here
      selectedTaskStart = nil
      
    case .run:
      self.selectedTaskStart = Date()
      self.topLabelOutlet.text = "Complete your Tasks"
      self.tasksWordOutlet.isHidden = false
      self.completeWordOutlet.isHidden = false
      self.wonCountOutlet.isHidden = false
      self.stepperOutlet.isHidden = true
      self.mainTimerOutlet.start()
      self.leftTimerOutlet.resume()
      
    case .inactive:
      self.taskSelect()
    }
          self.view.layoutSubviews()
  }
  
    func circleCounterTimeDidExpire(circleTimer: AppusCircleTimer) {
      switch circleTimer {
      case mainTimerOutlet:
        print("Main timer expired")
      case leftTimerOutlet:
        print("Left timer expired")
        drawScreen()
      case  rightTimerOutlet:
        print("Right timer expired")
      default:
        fatalError("Delegate method called by non-existant timer")
      }
    }
    
  private func setupLeftTimer(with task: TaskyNode)
  {
    if let estimate = task.secondsEstimated.value
    {
      switch estimate > task.secondsElapsed
      {
      case true:
        print("elapsed time is less than estimate")
        setupUnderEstimate(tracker: leftTimerOutlet, for: task)
      case false:
        print("elapsed time is greater than estimate")
        setupOverEstimate(tracker: leftTimerOutlet, for: task)
      }
    }
    else {
      print("estimate is nil")
      setupNilEstimate(tracker: leftTimerOutlet, for: task)
    }

    self.setStandardTimerColors(for: self.leftTimerOutlet)
    self.leftTimerOutlet.start()
    self.leftTimerOutlet.stop()
  }
  
  private func setupNilEstimate(tracker: AppusCircleTimer, for task: TaskyNode) {

    tracker.isBackwards = false
    tracker.totalTime = TimeInterval.init(60 * 15)
    tracker.elapsedTime = TimeInterval.init(task.secondsElapsed)
  }
  
  private func setupUnderEstimate(tracker: AppusCircleTimer, for task: TaskyNode) {
    //temporary estimate placeholder
    tracker.totalTime = TimeInterval.init(60 * 5)
    tracker.elapsedTime = TimeInterval.init(task.secondsElapsed)
    tracker.isBackwards = true
  }
  
  private func setupOverEstimate(tracker: AppusCircleTimer, for task: TaskyNode) {
    tracker.activeColor = UIColor.red
    tracker.pauseColor = UIColor.red
    //temporary totalTime placeholder
    tracker.totalTime = TimeInterval.init(60 * 45)
    tracker.elapsedTime = TimeInterval.init(task.secondsElapsed - task.secondsEstimated.value!)
    tracker.isBackwards = false
  }

  private func setStandardTimerColors(for timer: AppusCircleTimer) {
    timer.activeColor = UIColor.yellow //elapsed.paused
    timer.inactiveColor = UIColor.darkGray //remaini
    timer.pauseColor = UIColor.green//elapsed.running
  }
  
  private func taskSelect()
  {
    hibernate(timer: self.mainTimerOutlet)
    hibernate(timer: self.leftTimerOutlet)
    hibernate(timer: self.rightTimerOutlet)
    self.stepperOutlet.isHidden = true
    self.completeWordOutlet.isHidden = true
    self.tasksWordOutlet.isHidden = true
   // self.mainTimerOutlet.totalTime = 0.0
   // self.mainTimerTap(self)
    self.topLabelOutlet.text = "No Task Selected"
  }
  
  private func hibernate(timer: AppusCircleTimer)
  {

    let fadedAlpha = CGFloat.init(0.25)
    self.doneSwitchOutlet.isOn = false
    self.doneSwitchOutlet.isEnabled = false
    timer.reset()
    timer.elapsedTime = 0.0
    timer.isActive = false
    timer.totalTime = 0.0
    timer.stop()
    timer.reset()
    timer.alpha = fadedAlpha
    self.taskTitleLabel.textColor = UIColor.gray
    self.taskDescriptionLabel.textColor = UIColor.gray
    self.taskTitleLabel.text = "<select a task>"
    self.taskTitleLabel.isUserInteractionEnabled = true
    self.taskDescriptionLabel.text = ""
    switch timer.accessibilityIdentifier
    {
    case "leftTimer":
      self.timerLeftLabel.textColor = UIColor.gray
    case "rightTimer":
      self.timerRightLabel.textColor = UIColor.gray
    default:
      print("Main Timer.  No Label to Fade")
    }
    
  }
  
  private func wakeUp(timer: AppusCircleTimer)
  {
    let stdAlpha = CGFloat.init(1.0)
    self.doneSwitchOutlet.isOn = true
    self.doneSwitchOutlet.isEnabled = true
    timer.isActive = true
    timer.alpha = stdAlpha
    self.taskTitleLabel.textColor = UIColor.black
    self.taskDescriptionLabel.textColor = UIColor.black
    switch timer.accessibilityIdentifier
    {
    case "leftTimer":
      self.timerLeftLabel.textColor = UIColor.black
    case "rightTimer":
      self.timerRightLabel.textColor = UIColor.black
    default:
      print("Main Timer.  No Label to Unfade")
    }
  }

  
  //MARK: Task mutation methods
  private func deselect(task: TaskyNode)
  {
    TaskyNodeEditor.sharedInstance.setElapsedTime(of: task, to: task.secondsElapsed + loggedTaskTime)
    self.selectedTask = nil
    self.loggedTaskTime = 0
    self.selectedTaskStart = nil
  }

  @objc func pushToTasks(_ sender: Any?)
  {
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let tasksViewController = storyBoard.instantiateViewController(withIdentifier: "chooseTask") as! ChooseTaskTableViewController
    //let toTasksSegue = UIStoryboardSegue.init(identifier: "toTasks", source: self, destination: tasksViewController)
    //toTasksSegue.perform()
    tasksViewController.chooseTaskDelegate = self
    tasksViewController.availableTasks = Array(TaskyNodeEditor.sharedInstance.database.filter("completionDate == nil"))
    present(tasksViewController, animated: true, completion: nil)
  }
  
  func chosenTask(task: TaskyNode) {
    self.selectedTask = task
    self.timerState = .setup
    drawScreen()
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

  @IBAction func taskTitleTap(_ sender: Any) {
    self.pushToTasks(self)
    print("Task title tapped...")
  }
  @IBAction func mainTimerTap(_ sender: Any) {
    print("Main timer tapped...")
      switch self.timerState
      {
      case .setup:
        self.timerState = .run
      case .run:
        self.timerState = .pause
      case .pause:
        self.timerState = .run
      case .inactive:
        self.timerState = .inactive
      }
    print("Main timer state: \(self.timerState)")
      drawScreen()
    }
  
  @IBAction func doneSwitchAction(_ sender: UISwitch)
  {
    
  }
  
    

     // MARK: - Navigation

}
