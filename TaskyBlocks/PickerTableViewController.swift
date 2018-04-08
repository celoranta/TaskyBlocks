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

class PickerTableViewController: UITableViewController {
  
  var superSet: Set<TaskyNode>?
  var superArray: [TaskyNode] = []
  var contextItem: TaskyNode?
  var pickerTableViewDelegate: PickerTableViewDelegate?
  
  var tableViewTitle: String?
  var subArray: [TaskyNode] = []
  var updatedSubArray: [TaskyNode] = []
  var selectedTask: TaskyNode!
  var activeTasks: [TaskyNode]!
  
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
    
    guard pickerTableViewDelegate != nil
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
  
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
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
    }
    return cell
  }

   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
  
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    let delegate = self.pickerTableViewDelegate as! PickerTableViewDelegate
    delegate.updatedSubset(from: self)
    
  }
  
}
