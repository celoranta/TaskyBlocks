//
//  PerformViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import AppusCircleTimer
import RealmSwift //Remove once a read-only realm is created

class PerformViewController: UIViewController, UIPickerViewDelegate,  UIPickerViewDataSource, AppusCircleTimerDelegate
  
{
  @IBOutlet weak var quitButtonOutlet: UIBarButtonItem!
  @IBOutlet weak var winTasksButton: UIBarButtonItem!
  @IBOutlet weak var tasksLabel: UILabel!
  @IBOutlet weak var completeLabel: UILabel!
  @IBOutlet weak var tasksCompleteLabel: UILabel!
  @IBOutlet weak var navBar: UINavigationItem!
  @IBOutlet weak var topScreenLabel2: UILabel!
  @IBOutlet weak var topScreenLabel1: UILabel!
  @IBOutlet weak var sprintTimer: AppusCircleTimer!
  @IBOutlet weak var taskPicker: UIPickerView!
  @IBOutlet weak var leftSmallTimer: AppusCircleTimer!
  @IBOutlet weak var rightSmalLTimer: AppusCircleTimer!
  @IBOutlet weak var descriptionOutlet: UILabel!
  
  var tasksData: Results<TaskyNode>!
  var timeToSet: Double = 45.00 * 60
  var pickerArray: Results<TaskyNode>!
  var performedTask: TaskyNode!
  var titleButton: UIButton!
  var tasksComplete: Int = 0
  var filter = "completionDate == nil"
  
  var realm: Realm!
  var activeTaskySet: Set<TaskyNode>!

  
  override func viewDidLoad()
  {
    self.descriptionOutlet.text = "Task Desription: " + performedTask.taskDescription
    super.viewDidLoad()
    try! realm = Realm()
    self.navigationController?.navigationBar.isHidden = true
    pickerArray = Array(realm.objects(TaskyNode.self).filter(filter)
    titleButton = UIButton()
    navBar.titleView = titleButton
    titleButton.translatesAutoresizingMaskIntoConstraints = false
    titleButton.setTitle(performedTask.title, for: .normal)
    titleButton.setTitleColor(UIColor.black, for: .normal)
    let titleButtonSelector = NSSelectorFromString("titleButtonClick")
    titleButton.addTarget(self, action: titleButtonSelector, for: .touchUpInside)
    tasksLabel.isHidden = true
    completeLabel.isHidden = true
    tasksCompleteLabel.isHidden = true
    
    leftSmallTimer.thickness = 7
    rightSmalLTimer.thickness = 7
    leftSmallTimer.alpha = 0.4
    rightSmalLTimer.alpha = 0.4
    leftSmallTimer.isBackwards = true
    rightSmalLTimer.isBackwards = true
    leftSmallTimer.inactiveColor = UIColor.blue
    rightSmalLTimer.inactiveColor = UIColor.blue
    
    sprintTimer.delegate = self
    sprintTimer.elapsedTime = 0
    sprintTimer.isBackwards = true
    sprintTimer.totalTime = timeToSet
    sprintTimer.start()
    topScreenLabel1.text = "Push yourself..."
    topScreenLabel2.text = "How many tasks can you complete?"
    taskPicker.showsSelectionIndicator = true
    taskPicker.isHidden = true
    taskPicker.isUserInteractionEnabled = false
    refreshView()
  }
  
  fileprivate func checkPermanent()
  {
    if self.performedTask.isPermanent == 1
    {
      self.winTasksButton.isEnabled = false
      self.navigationController?.navigationBar.isHidden = false
      self.navigationController?.popToRootViewController(animated: true)
    }
    else
    {
      self.winTasksButton.isEnabled = true
    }
  }
  
  func refreshView()
  {
    self.taskPicker.reloadAllComponents()
    self.taskPicker.setNeedsDisplay()
    tasksCompleteLabel.text = "\(tasksComplete)"
    forceRow()
    checkPermanent()

  }
  
  //MARK: Timer delegate funtions
  func circleCounterTimeDidExpire(circleTimer: AppusCircleTimer)
  {
    taskPicker.isUserInteractionEnabled = false
    topScreenLabel1.text = "Time's Up!"
    topScreenLabel2.text = "You've earned a break."
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?)
  {
    if motion == .motionShake
    {
      shuffle()
    }
  }
  
  public func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return self.pickerArray.count
  }
  
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
  {
    return pickerArray[row].title
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    self.performedTask = pickerArray[row]
    print("selected new task: \(performedTask)")
    checkPermanent()
    titleButton.setTitle(performedTask.title, for: .normal)
    self.descriptionOutlet.text = "Task Description: " + performedTask.taskDescription 
    taskPicker.isHidden = true
    descriptionOutlet.isHidden = false
    taskPicker.isUserInteractionEnabled = false
  }
  
  func forceRow()
  {
    if let row = pickerArray.index(of: performedTask)
    {
      taskPicker.selectRow(row, inComponent: 0, animated: true)
      self.pickerView(taskPicker, didSelectRow: row, inComponent: 1)
    }
  }
  
  func shuffle()
  {
    let arrayMaxIndexInt = (pickerArray.count)
    let arrayMaxIndexInt32 = UInt32(arrayMaxIndexInt)
    let randomIndexUInt32 = arc4random_uniform(arrayMaxIndexInt32)
    let randomIndex = Int(randomIndexUInt32)
    performedTask = pickerArray[randomIndex]
    if performedTask.isPermanent == 1 && pickerArray.count > 1
    {
      shuffle()
    }
    refreshView()
  }
  
  @objc func unwindSegueToPomodoro(sender: Any?)
  {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func titleButtonClick()
  {
    if taskPicker.isHidden == true
    {
      taskPicker.isHidden = false
      taskPicker.isUserInteractionEnabled = true
      descriptionOutlet.isHidden = true
    }
    else
    {
      taskPicker.isHidden = true
      taskPicker.isUserInteractionEnabled = false
    }
  }
  
  func changeBackButton()
  {
    quitButtonOutlet.title = "Good Work."
    refreshView()
  }
  
  @IBAction func markCompletePress(_ sender: Any)
  {
    TaskyNodeEditor.sharedInstance.complete(task: performedTask)
    completeLabel.isHidden = false
    tasksLabel.isHidden = false
    tasksCompleteLabel.isHidden = false
    tasksComplete += 1
    tasksCompleteLabel.text = "\(tasksComplete)"
    if self.pickerArray.filter("isPermanent == -1").count == 0
    {
      changeBackButton()
    }
    guard pickerArray.count != 0
      else
    {
      unwindSegueToPomodoro(sender: self)
      return
    }
    shuffle()
  }
  
  //Mark: Actions
  @IBAction func quitButton(_ sender: Any)
  {
    unwindSegueToPomodoro(sender: self)
  }
}
