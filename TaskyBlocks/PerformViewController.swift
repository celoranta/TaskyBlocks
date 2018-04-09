//
//  PerformViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import AppusCircleTimer

class PerformViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
  @IBOutlet weak var sprintTimer: AppusCircleTimer!
  @IBOutlet weak var taskPicker: UIPickerView!
  @IBAction func taskDetailButton(_ sender: Any) {
  }
  
  var tasksData: TaskDataSource!
  var timeToSet: Double = 45.00 * 60
  var pickerArray: [TaskyNode]?
  var performedTask: TaskyNode?
  
  var unwrappedPickerArray: [TaskyNode]!
  var unwrappedPerformedTask: TaskyNode!

  override func viewDidLoad() {
        super.viewDidLoad()
    guard let uPickerArray = pickerArray
      else
    {
      fatalError("Fatal Error:  Perform VC was fed a nil picker Array")
    }
    
      guard let uPerformedTask = performedTask
      else
    {
      fatalError("Fatal Error: Perform VC was fed a nil performedTask")
    }
    self.unwrappedPickerArray = uPickerArray
    self.unwrappedPerformedTask = uPerformedTask

      sprintTimer.elapsedTime = 0
      sprintTimer.isBackwards = true
      sprintTimer.totalTime = timeToSet
      sprintTimer.start()
      taskPicker.showsSelectionIndicator = true
      refreshView()
    }
  
  func refreshView()
  {
    self.taskPicker.reloadAllComponents()
    self.taskPicker.setNeedsDisplay()
  }

  public func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return unwrappedPickerArray.count
  }
  
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
  {
    return unwrappedPickerArray[row].title
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    self.unwrappedPerformedTask = unwrappedPickerArray[row]
  }
  
  @IBAction func markCompletePress(_ sender: Any) {
    tasksData.setComplete(for: unwrappedPerformedTask, on: Date())
    let index = unwrappedPickerArray.index(of: unwrappedPerformedTask)
    if let uindex = index
    {
      unwrappedPickerArray.remove(at: uindex)
    }
    refreshView()
  }
  @IBAction func quitButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
