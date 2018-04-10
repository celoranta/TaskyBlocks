//
//  PomodoroViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit


class PomodoroViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, TaskDetailDataSource
{
  
  @IBOutlet weak var goTimeButton: UIButton!
  @IBOutlet weak var taskPicker: UIPickerView!
  @IBOutlet weak var durationTimeLabel: UILabel!
  @IBOutlet weak var taskDetailButton: UIButton!
  
  var tasksData: TaskDataSource?
  var segueToDetail: UIStoryboardSegue!
  var timerSetValue: Double = 2700.00
  var performViewController: PerformViewController!
  
  //These two should be refactored out, as they don't need to be exposed
  var pickerData: Set<TaskyNode>?
  var pickerSet: Set<TaskyNode>!
  //
  
  var selectedItem: TaskyNode!
  var pickerArray: [TaskyNode]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    prepareView()
  }
  
  public func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
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
    self.goTimeButton.isEnabled = true
    self.taskDetailButton.isEnabled = true
    self.goTimeButton.alpha = 1
    self.selectedItem = pickerArray[row]
  }
  
  fileprivate func prepareView()
  {
    taskDetailButton.isEnabled = false
    goTimeButton.isEnabled = false
    goTimeButton.alpha = 0.25
    goTimeButton.layer.cornerRadius = 25
    goTimeButton.layer.borderWidth = 5
    goTimeButton.layer.borderColor = UIColor.darkGray.cgColor
    if let unwrappedTasksData = tasksData
    {
      pickerData = unwrappedTasksData.serveTaskData()
    }
    
    if let unwrappedPickerData = pickerData
    {
      pickerSet = unwrappedPickerData
    }
    taskPicker.dataSource = self
    taskPicker.delegate = self
    taskPicker.showsSelectionIndicator = true
    var displayArray: [TaskyNode] = []
    for task in pickerSet
    {
      displayArray.append(task)
    }
    pickerArray = displayArray
    if pickerArray.count != 0
    {
      self.selectedItem = pickerArray[0]
    }
    else
    {
      
    }
    // reloadInputViews()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == "detailSegueFromPomodoro"
    {
      let detailNavController = segue.destination as! UINavigationController
      let detailViewController = detailNavController.topViewController as! DetailViewController
      detailViewController.taskDetailDataSource = self
      detailViewController.tasksData = tasksData
    }
    if segue.identifier == "pomodoroToPerform"
    {
      performViewController = segue.destination as! PerformViewController
      performViewController.timeToSet = self.timerSetValue
      performViewController.pickerArray = self.pickerArray
      performViewController.performedTask = self.selectedItem
      performViewController.tasksData = self.tasksData
    }
  }
  
  @IBAction func goDoubleTap(_ sender: UIButton)
  {
  }
  
  @IBOutlet weak var durationStepperOut: UIStepper!
  @IBAction func durationStepper(_ sender: Any)
  {
    let duration = durationStepperOut.value
    timerSetValue = duration * 60
    print(duration)
    let roundedDuration = Int(duration)
    durationTimeLabel.text = "\(roundedDuration) min"
  }
  
  func returnSelectedTask() -> TaskyNode
  {
    return self.selectedItem
  }
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
