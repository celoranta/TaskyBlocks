//
//  PerformViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import AppusCircleTimer

class PerformViewController: UIViewController, UIPickerViewDelegate,  UIPickerViewDataSource, AppusCircleTimerDelegate {
  
  
  @IBOutlet weak var topScreenLabel2: UILabel!
  @IBOutlet weak var topScreenLabel1: UILabel!
  @IBOutlet weak var sprintTimer: AppusCircleTimer!
  @IBOutlet weak var taskPicker: UIPickerView!
  @IBAction func taskDetailButton(_ sender: Any) {
  }
  
  var tasksData: TaskDataSource!
  var timeToSet: Double = 45.00 * 60
  var pickerArray: [TaskyNode]!
  var performedTask: TaskyNode!


  override func viewDidLoad() {
        super.viewDidLoad()
    
      sprintTimer.delegate = self
      sprintTimer.elapsedTime = 0
      sprintTimer.isBackwards = true
      sprintTimer.totalTime = timeToSet
      sprintTimer.start()
      topScreenLabel1.text = "Push yourself..."
      topScreenLabel2.text = "How many tasks can you complete?"
      taskPicker.showsSelectionIndicator = true
      refreshView()
    }
  
  func refreshView()
  {
    self.taskPicker.reloadAllComponents()
    self.taskPicker.setNeedsDisplay()
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
  
  @IBAction func shuffleButton(_ sender: Any) {

  }
  
  @IBAction func markCompletePress(_ sender: Any) {
    tasksData.setComplete(for: performedTask, on: Date())
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
