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




class ComboViewController: UIViewController, AppusCircleTimerDelegate, ChooseTask {

  enum TimerState
  {
    case setup, pause, run, inactive
  }
  
  enum TaskTimerMode
  {
    case noEstimate, underEstimate, overEstimate
  }
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
  
  var selectedTask: TaskyNode? = nil
  var elapsedSinceLog: Int? = nil
  var timerState: TimerState = .setup
  var taskTimerMode: TaskTimerMode = .noEstimate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("Running ViewDidLoad for ComboVC")
    mainTimerOutlet.delegate = self
    leftTimerOutlet.delegate = self
    rightTimerOutlet.delegate = self
    
    mainTimerOutlet.isBackwards = true
    setStandardTimerColors(for: mainTimerOutlet)
    
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
  
  fileprivate func logTaskTimerToTask(_ taskToUpdate: TaskyNode) {
    print("Running logTaskTimerToTask")
    var newElapsedTime: Int = 0
    switch taskTimerMode
    {
    case .noEstimate, .underEstimate:
      newElapsedTime = Int(leftTimerOutlet.elapsedTime)
    case.overEstimate:
      newElapsedTime = Int(leftTimerOutlet.elapsedTime) + selectedTask!.secondsEstimated.value!
    }
    TaskyNodeEditor.sharedInstance.setElapsedTime(of: taskToUpdate, to: Int(newElapsedTime))
    self.elapsedSinceLog = Int(leftTimerOutlet.elapsedTime)
  }

  fileprivate func logTaskElapsedToTaskTimer(task: TaskyNode)
  {
      leftTimerOutlet.elapsedTime = TimeInterval.init(task.secondsElapsed)

  }
  
  override func viewWillDisappear(_ animated: Bool) {
    print("Combo controller called 'view will disappear'")
    if let taskToUpdate = selectedTask
    {
      logTaskTimerToTask(taskToUpdate)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    print("Running ViewWillAppear")
    if let uTask = selectedTask {
    setupLeftTimer(with: uTask)
    }
    drawScreen()
  }
  
  fileprivate func activeTimerConfig(with task: TaskyNode) {
    print("Running activeTimerConfig")
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
    print("Running drawScreen")
    if let uSelectedTask = selectedTask
    {
      logTaskTimerToTask(uSelectedTask)
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

    case .run:
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
      print("Running circleCounterTimeDidExpire")
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
    print("Running setupLeftTimer")
    leftTimerOutlet.reset()
        self.setStandardTimerColors(for: self.leftTimerOutlet)
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

    self.leftTimerOutlet.start()
    self.leftTimerOutlet.stop()
  }
  
  private func setupNilEstimate(tracker: AppusCircleTimer, for task: TaskyNode) {
    print("Running setupNilEstimate")
    self.taskTimerMode = .noEstimate
    tracker.isBackwards = false
    tracker.totalTime = TimeInterval.init(60 * 15)
    tracker.elapsedTime = TimeInterval.init(task.secondsElapsed)
  }
  
  private func setupUnderEstimate(tracker: AppusCircleTimer, for task: TaskyNode) {
    print("Running setup underEstimate")
    self.taskTimerMode = .underEstimate
    tracker.totalTime = TimeInterval.init(task.secondsEstimated.value!)
    tracker.elapsedTime = TimeInterval.init(task.secondsElapsed)
    tracker.isBackwards = true
  }
  
  private func setupOverEstimate(tracker: AppusCircleTimer, for task: TaskyNode) {
    print("Running setupOverEstimate")
    self.taskTimerMode = .overEstimate
    tracker.activeColor = UIColor.red
    tracker.pauseColor = UIColor.red
    //temporary totalTime placeholder
    tracker.totalTime = TimeInterval.init(60 * 45)
    tracker.elapsedTime = TimeInterval.init(task.secondsElapsed - task.secondsEstimated.value!)
    tracker.isBackwards = false
  }

  private func setStandardTimerColors(for timer: AppusCircleTimer) {
    print("Running setStandardTimerColors")
    timer.activeColor = UIColor.yellow //elapsed.paused
    timer.inactiveColor = UIColor.darkGray //remaini
    timer.pauseColor = UIColor.green//elapsed.running
  }
  
  private func taskSelect()
  {
    print("Running task select")
    hibernate(timer: self.mainTimerOutlet)
    hibernate(timer: self.leftTimerOutlet)
    hibernate(timer: self.rightTimerOutlet)
    self.stepperOutlet.isHidden = true
    self.completeWordOutlet.isHidden = true
    self.tasksWordOutlet.isHidden = true
    self.topLabelOutlet.text = "No Task Selected"
  }
  
  private func hibernate(timer: AppusCircleTimer)
  {
    print("Running hibernate")
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
    print("Running wakeUp")
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

  @objc func pushToTasks(_ sender: Any?)
  {
    print("Running pushToTasks")
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let tasksViewController = storyBoard.instantiateViewController(withIdentifier: "chooseTask") as! ChooseTaskTableViewController
    tasksViewController.chooseTaskDelegate = self
    tasksViewController.availableTasks = Array(TaskyNodeEditor.sharedInstance.database.filter("completionDate == nil"))
    present(tasksViewController, animated: true, completion: nil)
  }
  
  func chosenTask(task: TaskyNode) {
    print("Running chosenTask")
    loadChosenTask(task: task)
    if self.timerState == .inactive
    {
      self.timerState = .setup
    }
    drawScreen()
  }
  
  func loadChosenTask(task: TaskyNode) {
    print("Running loadChosenTask")
    self.selectedTask = task
    logTaskElapsedToTaskTimer(task: task)
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
