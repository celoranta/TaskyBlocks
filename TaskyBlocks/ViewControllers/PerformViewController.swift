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

class PerformViewController: UIViewController, UIPickerViewDelegate,  UIPickerViewDataSource, AppusCircleTimerDelegate {
  
  
  @IBOutlet weak var tasksLabel: UILabel!
  @IBOutlet weak var completeLabel: UILabel!
  @IBOutlet weak var tasksCompleteLabel: UILabel!
  @IBOutlet weak var navBar: UINavigationItem!
  @IBOutlet weak var topScreenLabel2: UILabel!
  @IBOutlet weak var topScreenLabel1: UILabel!
  @IBOutlet weak var sprintTimer: AppusCircleTimer!
  @IBOutlet weak var taskPicker: UIPickerView!
  @IBAction func taskDetailButton(_ sender: Any) {
  }
  
  var tasksData: Results<TaskyNode>!
  var timeToSet: Double = 45.00 * 60
  var pickerArray: [TaskyNode]!
  var performedTask: TaskyNode!
  var titleButton: UIButton!
  var tasksComplete: Int = 0
  
  var realm: Realm!
  var activeTaskySet: Set<TaskyNode>!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    try! realm = Realm()
    let tasksData = realm.objects(TaskyNode.self)
    
    pickerArray = Array.init(tasksData)
    //activeTaskySet = Set(tasks)
    titleButton = UIButton()
    navBar.titleView = titleButton
    titleButton.translatesAutoresizingMaskIntoConstraints = false
    titleButton.setTitle(performedTask.title, for: .normal)
    titleButton.setTitleColor(UIColor.black, for: .normal)
    let titleButtonSelector = NSSelectorFromString("titleButtonClick")
    titleButton.addTarget(self, action: titleButtonSelector, for: .touchUpInside)
    
    //let titleSize = CGSize.init(width: 100, height: 50)
    tasksLabel.isHidden = true
    completeLabel.isHidden = true
    tasksCompleteLabel.isHidden = true
    
    
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
  
  func refreshView()
  {
    self.taskPicker.reloadAllComponents()
    self.taskPicker.setNeedsDisplay()
    tasksCompleteLabel.text = "\(tasksComplete)"
    
    forceRow()
  }
  
  //MARK: Timer delegate funtions
  func circleCounterTimeDidExpire(circleTimer: AppusCircleTimer) {
    taskPicker.isUserInteractionEnabled = false
    topScreenLabel1.text = "Time's Up!"
    topScreenLabel2.text = "You've earned a break."
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
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
    titleButton.setTitle(performedTask.title, for: .normal)
    taskPicker.isHidden = true
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
    let arrayMaxIndexInt = (pickerArray.count - 1)
    let arrayMaxIndexInt32 = UInt32(arrayMaxIndexInt)
    let randomIndexUInt32 = arc4random_uniform(arrayMaxIndexInt32)
    let randomIndex = Int(randomIndexUInt32)
    performedTask = pickerArray[randomIndex]
    refreshView()
  }
  
  @objc func titleButtonClick()
  {
    if taskPicker.isHidden == true
    {
    taskPicker.isHidden = false
    taskPicker.isUserInteractionEnabled = true
    }
    else
    {
      taskPicker.isHidden = true
      taskPicker.isUserInteractionEnabled = false
    }
  }
  
  @IBAction func shuffleButton(_ sender: Any) {
    
  }
  
  @IBAction func markCompletePress(_ sender: Any) {
    performedTask.markAsCompleted(on: Date())
    completeLabel.isHidden = false
    tasksLabel.isHidden = false
    tasksCompleteLabel.isHidden = false
    tasksComplete += 1
    tasksCompleteLabel.text = "\(tasksComplete)"
    let index = pickerArray.index(of: performedTask)
    var uindex2 = 0
    if let uindex = index
    {
      pickerArray.remove(at: uindex)
      if uindex >= pickerArray.count
      {
        uindex2 = uindex - 1
      }
    }
    guard pickerArray.count != 0
      else
    {
      quitButton(self)
      return
    }
    performedTask = pickerArray[uindex2]
    refreshView()
  }
  
  //Mark: Actions
  @IBAction func quitButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
}
