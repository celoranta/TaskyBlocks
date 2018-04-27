//
//  PomodoroViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift //To be removed once a read-only Realm is created for view controllers


class PomodoroViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, TaskDetailDataSource
{
  
  //MARK: Outlets
  @IBOutlet weak var goTimeButton: UIButton!
  @IBOutlet weak var taskPicker: UIPickerView!
  @IBOutlet weak var durationTimeLabel: UILabel!
  @IBOutlet weak var durationStepperOut: UIStepper!
  
  //MARK: Properties
  var segueToDetail: UIStoryboardSegue!
  var timerSetValue: Double = 2700.00
  var performViewController: PerformViewController!
  var realm: Realm!
  var activeTaskySet: Results<TaskyNode>!
  var filter = "completionDate == nil"
  var selectedItem: TaskyNode!
  var pickerArray: [TaskyNode]!
  
  //MARK: LifeCycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    try! realm = Realm()
    activeTaskySet = realm.objects(TaskyNode.self).filter(filter)
    prepareView()
    self.navigationItem.hidesBackButton = true
    self.goTimeButton.setTitle("Go Time!", for: .normal)
    self.goTimeButton.setTitle("Choose" , for: .disabled)
    let backButton = UIBarButtonItem.init(title: "Tasks", style: .plain, target: self, action: #selector(backToTasks))
    self.navigationItem.leftBarButtonItem = backButton
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    if activeTaskySet.count == 0
    {
      self.navigationController?.popToRootViewController(animated: true)
    }
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.isHidden = false
    prepareView()
  }
  
  fileprivate func prepareView()
  {
    
    goTimeButton.isEnabled = false
    goTimeButton.alpha = 0.25
    goTimeButton.layer.cornerRadius = 25
    goTimeButton.layer.borderWidth = 5
    goTimeButton.layer.borderColor = UIColor.darkGray.cgColor
    
    taskPicker.dataSource = self
    taskPicker.delegate = self
    taskPicker.showsSelectionIndicator = true
    
    pickerArray = Array.init(realm.objects(TaskyNode.self).filter(filter))
    pickerArray.sort(by: { $0.priorityApparent > $1.priorityApparent})
    pickerArray = pickerArray.filter({pickerArray.index(of: $0)! < 5})

//    if pickerArray.count != 0
//    {
//      self.selectedItem = pickerArray[0]
//    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if segue.identifier == "detailSegueFromPomodoro"
    {
      let detailNavController = segue.destination as! UINavigationController
      let detailViewController = detailNavController.topViewController as! DetailViewController
      detailViewController.taskDetailDataSource = self
    }
    if segue.identifier == "pomodoroToPerform"
    {
      performViewController = segue.destination as! PerformViewController
      performViewController.timeToSet = self.timerSetValue
      performViewController.performedTask = self.selectedItem
    }
  }
  
  //Mark: Picker View Delegate Methods
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
    self.goTimeButton.alpha = 1
    self.selectedItem = pickerArray[row]
  }
  
  func returnSelectedTask() -> TaskyNode
  {
    return self.selectedItem
  }
  
  //MARK: Action Methods
  @objc func backToTasks()
  {
    self.navigationController?.popToRootViewController(animated: true)
  }
  
  @IBAction func durationStepper(_ sender: Any)
  {
    let duration = durationStepperOut.value
    timerSetValue = duration * 60
    print(duration)
    let roundedDuration = Int(duration)
    durationTimeLabel.text = "\(roundedDuration) min"
  }
}
