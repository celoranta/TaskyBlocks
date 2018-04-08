//
//  DetailViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol TaskDetailDataSource {
  func returnSelectedTask () -> TaskyNode
}

class DetailViewController: UIViewController, PickerTableViewDelegate {

  
  var task:TaskyNode!
  var taskDetailDataSource: TaskDetailDataSource!
  var tasksData: TaskDataSource!
  
  @IBOutlet weak var taskTitleText: UITextField!
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var taskDescription: UITextView!
  @IBOutlet weak var priorityLevelLabel: UILabel!
  @IBOutlet weak var isPrimalStatusLabel: UILabel!
  @IBOutlet weak var isActionableStatusLabel: UILabel!
  @IBOutlet weak var parentsListButton: UIButton!
  @IBOutlet weak var childListLabel: UILabel!
  @IBOutlet weak var dependeesListLabel: UILabel!
  @IBOutlet weak var dependentsListLabel: UILabel!
  @IBOutlet weak var primalsListLabel: UILabel!
  @IBOutlet weak var taskDateLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard taskDetailDataSource != nil
      else
    {
      fatalError("No data source set for detail view")
    }
    let task = taskDetailDataSource.returnSelectedTask()
    self.taskTitleText.text = task.title
    self.taskTitleText.enablesReturnKeyAutomatically = true
    self.taskDescription.text = task.taskDescription
    self.uuidLabel.text = task.taskId
    self.priorityLevelLabel.text = task.priorityApparent.description
    self.isPrimalStatusLabel.text = task.isPrimal.description
    self.isActionableStatusLabel.text = task.isActionable.description
    self.taskDateLabel.text = task.taskDate.description
    var parentsString = ""
    for parent in task.parents
    {
      parentsString.append(parent.title + ", ")
    }
    parentsListButton.setTitle(parentsString, for: .normal)
  }
  
  //MARK: Actions
  @IBAction func backButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  //MARK: PickerTableView Delegate
  func updatedSubset(from table: PickerTableViewController) {
    task.parents = table.updatedSubArray
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! PickerTableViewController
    destinationVC.contextItem = task
    destinationVC.superSet = tasksData.serveTaskData()
    destinationVC.pickerTableViewDelegate = self
    if segue.identifier == "pickerToParents"
    {
      destinationVC.subArray = task.parents
      destinationVC.title = "Task Parents"
    }
  }
}
