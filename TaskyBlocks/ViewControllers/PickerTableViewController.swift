//
//  PickerTableViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-07.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

protocol PickerTableViewDelegate
{
  // call provideUpdatedCollection(of relationship: TaskRelationship, for task: TaskyNode)
  func retrieveUpdatedCollection(from table: PickerTableViewController)//
  // call postUpdatedTaskSubcollection() -> (focusTask: TaskyNode, relationship: TaskRelationship, collection: [TaskyNode])
}

enum TaskRelationship: String
{
  case parents = "Parents", children = "Children", dependents = "Dependents", dependees = "Dependees"
}

class PickerTableViewController: UITableViewController
{
  var pickerTableViewDelegate: PickerTableViewDelegate!
  var taskSubListFilter: String!  //All tasks selected on this page
  var activeTasks: Results<TaskyNode>!
  var subArray: [TaskyNode] = []  //copy of selected task's property
  var delegateRequestedRelationshipType: TaskRelationship!
  var delegateRequestedRelationshipsOf: TaskyNode!
  var delegateRequestedRelationshipsAmong: Results<TaskyNode>!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    activeTasks = delegateRequestedRelationshipsAmong
  }
  
  //MARK: PickerTableView Delegate
  
  func postUpdatedTaskSubcollection() -> (focusTask: TaskyNode, relationship: TaskRelationship, collection: [TaskyNode])
  {
    return (delegateRequestedRelationshipsOf, delegateRequestedRelationshipType, subArray)
  }
  
  func provideUpdatedCollection(of relationship: TaskRelationship, for task: TaskyNode, within taskList: Results<TaskyNode>)
  {
    delegateRequestedRelationshipType = relationship
    delegateRequestedRelationshipsOf = task
    delegateRequestedRelationshipsAmong = taskList

    switch delegateRequestedRelationshipType
    {
    case .parents:
      subArray = Array.init(delegateRequestedRelationshipsOf.parents)
    case .children:
      subArray = Array.init(delegateRequestedRelationshipsOf.children)
    case .dependents:
      subArray = Array.init(delegateRequestedRelationshipsOf.consequents)
    case .dependees:
      subArray = Array.init(delegateRequestedRelationshipsOf.antecedents)
    case .none:
      fatalError("delegate requested unknown type or types")
    case .some(_):
      fatalError("delegate requested unknown type or types")
    }
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
      if activeTasks[indexPath.row] === delegateRequestedRelationshipsOf
      {
        cell.checkMarkButton.setTitle("X", for: .normal)
      }
    }
    return cell
  }
  
  // MARK: -Table View Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    var task: TaskyNode
    switch indexPath.section
    {
    case 0: task = subArray[indexPath.row]
    case 1: task = activeTasks[indexPath.row]
    default: fatalError("Picker returned out-of-bounds selection")
    }
    if task !== delegateRequestedRelationshipsOf
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
    pickerTableViewDelegate.retrieveUpdatedCollection(from: self)
  }
}
