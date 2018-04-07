//
//  PomodoroViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class PomodoroViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, TaskDetailDataSource {

  
  @IBOutlet weak var taskPicker: UIPickerView!
  var tasksData: TaskDataSource?
  var segueToDetail: UIStoryboardSegue!
  
  //These two should be refactored out, as they don't need to be exposed
  var pickerData: Set<TaskyNode>?
  var pickerSet: Set<TaskyNode>!
  var selectedItem: TaskyNode!
  var pickerArray: [TaskyNode]!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let unwrappedTasksData = tasksData
    {
      pickerData = unwrappedTasksData.crucials()
    }
    
    if let unwrappedPickerData = pickerData
    {
      pickerSet = unwrappedPickerData
    }
    taskPicker.dataSource = self
    taskPicker.delegate = self

    var crucialsArray: [TaskyNode] = []
    for task in pickerSet
    {
      crucialsArray.append(task)
    }
    pickerArray = crucialsArray
    self.selectedItem = pickerArray[0]
  }
  
  @available(iOS 2.0, *)
  public func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  @available(iOS 2.0, *)
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return pickerArray.count
  }
  
  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
  {
    return pickerArray[row].title
  }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    self.selectedItem = pickerArray[row]
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "detailSegueFromPomodoro"
    {
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.taskDetailDataSource = self
    }
  }
  
  func returnSelectedTask() -> TaskyNode {
    return self.selectedItem
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
