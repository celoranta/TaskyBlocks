//
//  PickerTableViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-07.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol PickerTableViewDelegate
{
  // to replace the subset of the contextItem
  // will be called by the pickerViewController upon save/close
  func updatedSubset(from table: PickerTableViewController) -> ()
}

class PickerTableViewController: UITableViewController
{
  var superSet: Set<TaskyNode>?
  var contextItem: TaskyNode?
  var pickerTableViewDelegate: PickerTableViewDelegate!
  var tableViewTitle: String?
 
  var activeTasks: [TaskyNode]!
  var selectedTask: TaskyNode!
  var subArray: [TaskyNode] = []  //copy of selected task's property
  var updatedSubArray: [TaskyNode] = [] //for query by delegate
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    guard let selectedTaskunwrapped = contextItem
      else
    {
      fatalError("Fatal error: no task loaded")
    }
    selectedTask = selectedTaskunwrapped
    subArray = Array.init(selectedTask.parents)
    
    guard let activeTasksUnwrapped = superSet
      else
    {
      fatalError("Fatal error: no active task list loaded")
    }
    activeTasks = Array.init(activeTasksUnwrapped)
    
    guard let pickerTableViewDelegateUnwrapped = pickerTableViewDelegate
      else
    {
      fatalError("Fatal error: no picker table view delegate assigned")
    }
    
    if let unwrappedTitle = tableViewTitle
    {
      self.title = unwrappedTitle
    }
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int
  {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    var rowQty: Int
    switch section
    {
    case 0: rowQty = subArray.count
    case 1: rowQty = activeTasks.count
    default:
      rowQty = 0
    }
    return rowQty
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! PickerTableViewCell
    let checkMark = "\u{2713}"
    if indexPath.section == 0
    {
      let task = subArray[indexPath.row]
      cell.checkMarkButton.setTitle(checkMark, for: .normal)
      cell.taskTitleLabel.text = task.title
    }
    if indexPath.section == 1
    {
      let task = activeTasks[indexPath.row]
      cell.checkMarkButton.setTitle("-", for: .normal)
      cell.taskTitleLabel.text = task.title
      if subArray.contains(task)
      {
        cell.checkMarkButton.setTitle(checkMark, for: .normal)
      }
      if activeTasks[indexPath.row] === contextItem
      {
        cell.checkMarkButton.setTitle("X", for: .normal)
      }
    }
    return cell
  }
  
  // MARK: -Table View Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var task: TaskyNode
    switch indexPath.section
    {
    case 0: task = subArray[indexPath.row]
    case 1: task = activeTasks[indexPath.row]
    default: fatalError("Picker returned out-of-bounds selection")
    }
    if task !== contextItem
    {
    self.toggleTaskInSubset(task: task)
    }
  }
  
  func toggleTaskInSubset(task: TaskyNode)
  {
    if let index = subArray.index(of: task)
    {
      subArray.remove(at: index)
    }
    else
    {
      subArray.append(task)
    }
    self.tableView.reloadData()
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
  }
  
  override func viewWillDisappear(_ animated: Bool)
  {
    super.viewWillDisappear(true)
    let delegate = self.pickerTableViewDelegate!
    delegate.updatedSubset(from: self)
  }
}
