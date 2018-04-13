//
//  DetailViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

protocol TaskDetailDataSource {
  func returnSelectedTask () -> TaskyNode
}

class DetailViewController: UIViewController, PickerTableViewDelegate, UITextViewDelegate, UITextFieldDelegate {

  
  //MARK: Outlets
  @IBOutlet weak var taskTitleText: UITextField!
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var taskDescription: UITextView!
  @IBOutlet weak var priorityLevelLabel: UILabel!
  @IBOutlet weak var isPrimalStatusLabel: UILabel!
  @IBOutlet weak var isActionableStatusLabel: UILabel!
  @IBOutlet weak var parentsListButton: UIButton!

  @IBOutlet weak var childrenListButton: UIButton!
  @IBOutlet weak var dependeesListButton: UIButton!
  @IBOutlet weak var dependentsListButton: UIButton!
  @IBOutlet weak var primalsListLabel: UILabel!
  @IBOutlet weak var taskDateLabel: UILabel!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var priorityDirectText: UITextField!
  @IBOutlet weak var completedSwitch: UISwitch!
  
  //MARK: Variables
  var task:TaskyNode!
  var taskDetailDataSource: TaskDetailDataSource!
  var pickerTableViewController: PickerTableViewController!
  var pickerViewRelationshipType: TaskRelationship!
 
  //Realm
  var realm: Realm!
  var activeDataSet: Set<TaskyNode>!
  
  //MARK: Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    try! realm = Realm()
    let tasks = realm.objects(TaskyNode.self)
    activeDataSet = Set(tasks)
    
    guard taskDetailDataSource != nil
      else
    {
      fatalError("No data source set for detail view")
    }
    task = taskDetailDataSource.returnSelectedTask()
    //self.refreshView()
  }

  override func viewWillAppear(_ animated: Bool) {
   if task.isPermanent != 1
    {
      self.completedSwitch.isEnabled = false
    }
    else
    {
     self.completedSwitch.isEnabled = true
    }
    self.refreshView()
  }
  
  //MARK: Actions
  @IBAction func backButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  @IBAction func addButton(_ sender: Any) {
    self.refreshView()
  }
  @IBAction func deleteButton(_ sender: Any) {

  }
  @IBAction func completedSwitchThrown(_ sender: Any) {

    TaskyBlockLibrary.realmEdit {
      self.task.markAsCompleted(on: Date())
    }
  }
  
  @IBAction func priorityLabelTap(_ sender: Any)
  {
    task.soundOff()
  }
  @IBAction func childrenButton(_ sender: Any)
  {
    pickerViewRelationshipType = .children
    performSegue(withIdentifier: "toDetailPicker", sender: self)
  }
  @IBAction func parentsButton(_ sender: Any)
  {
    pickerViewRelationshipType = .parents
    performSegue(withIdentifier: "toDetailPicker", sender: self)
  }
  @IBAction func dependeesButton(_ sender: Any)
  {
    pickerViewRelationshipType = .dependees
    performSegue(withIdentifier: "toDetailPicker", sender: self)
  }
  @IBAction func dependentsButton(_ sender: Any)
  {
    pickerViewRelationshipType = .dependents
    performSegue(withIdentifier: "toDetailPicker", sender: self)
  }
  
  fileprivate func refreshView()
  {
    self.priorityDirectText.clearsOnBeginEditing = true
    self.priorityDirectText.keyboardType = .numbersAndPunctuation
    if let uPriorityDirect = task.priorityDirect.value
    { self.priorityDirectText.text = "\(uPriorityDirect)"
    }
    else
    { self.priorityDirectText.text = "<not set>"
    }
    self.taskTitleText.text = task.title
    self.taskTitleText.enablesReturnKeyAutomatically = true
    self.taskDescription.placeholder = "please enter a description"
    self.taskDescription.text = task.taskDescription
    self.uuidLabel.text = task.taskId
    self.priorityLevelLabel.text = task.priorityApparent.description
    self.isPrimalStatusLabel.text = task.isPrimal.description
    self.isActionableStatusLabel.text = task.isActionable.description
    self.taskDateLabel.text = task.taskDate.description
    self.completedSwitch.isOn = task.isComplete
    
    var parentsString = ""
    for parent in task.parents
    {
      parentsString.append(parent.title + ", ")
    }
    if parentsString == ""
    {
      parentsString = "<none>"
    }
    
    var childrenString = ""
    for child in task.children
    {
      childrenString.append(child.title + ", ")
    }
    if childrenString == ""
    {
      childrenString = "<none>"
    }
    
    var antecedentString = ""
    for antecedent in task.antecedents
    {
      antecedentString.append(antecedent.title + ", ")
    }
    if antecedentString == ""
    {
      antecedentString = "<none>"
    }
    
    var consequentString = ""
    for consequent in task.consequents
    {
      consequentString.append(consequent.title + ", ")
    }
    if consequentString == ""
    {
      consequentString = "<none>"
    }
    parentsListButton.setTitle(parentsString, for: .normal)
    childrenListButton.setTitle(childrenString, for: .normal)
    dependentsListButton.setTitle(consequentString, for: .normal)
    dependeesListButton.setTitle(antecedentString, for: .normal)
   // DISABLED deleteButton.isEnabled = tasksData.serveTaskData().count > 1
  }
  
  //MARK: PickerTableView Delegate
  
  
  func retrieveUpdatedCollection(from table: PickerTableViewController)
  {
    realm.beginWrite()
    let returnPickerData = table.postUpdatedTaskSubcollection()
    switch returnPickerData.relationship
    {
    case .parents:
      task.removeAsChildToAll()
      for parent in returnPickerData.collection
      {
        task.addAsChildTo(newParent: parent)
      }
      print("picker returned parents")
    case .children:
      print("picker returned children")
      
      task.removeAsParentToAll()
      for child in returnPickerData.collection
      {
        task.addAsParentTo(newChild: child)
      }
    case .dependents:
      task.removeAsAntecedentToAll()
      for consequent in returnPickerData.collection
      {
        task.addAsAntecedentTo(newConsequent: consequent)
      }
      print("picker returned dependents")
      
    case .dependees:
      task.removeAsConsequentToAll()
      for antecedent in returnPickerData.collection
      {
        task.addAsConsequentTo(newAntecedent: antecedent)
      }
      print("picker returned dependees")

    }
    try! realm.commitWrite()
    refreshView()
  }
  
  //MARK: Text Field Delegate
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == taskTitleText
    {
      textField.clearsOnBeginEditing = true
    }
    if textField == priorityDirectText
    {
      textField.clearsOnBeginEditing = true
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == taskTitleText
    {
      let inputString = textField.text ?? ""
      task.title = inputString
    }
    if textField == priorityDirectText
    {
      switch string
      {
      case "0","1","2","3","4","5","6","7","8","9":
        return true ///
      case ".":
        let array = Array(priorityDirectText.text!)
        var decimalCount = 0
        for character in array {
          if character == "." {
            decimalCount += 1
          }
        }
        if decimalCount == 1 {
          return false ///
        } else {
          return true ///
        }
      default:
        let array = Array(string)
        if array.count == 0 {
          return true ///
        }
        return false ///
      }
    }
    return true ///
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    taskTitleText.resignFirstResponder()
    priorityDirectText.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField)
  {
    realm.beginWrite()
    if textField == priorityDirectText
    {
      if let unwrappedText = priorityDirectText.text
      {
        task.priorityDirect.value = ((unwrappedText as NSString).doubleValue)
      }
    }
    _ = task.updateMyPriorities()
    try! realm.commitWrite()
    refreshView()
  }
  
  //MARK: Text View Delegate
  
  func textViewDidChange(_ textView: UITextView) {
    if textView == taskDescription
    {
      let inputString = textView.text ?? ""
      task.taskDescription = inputString
    }
  }
  
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    if textView == taskDescription
    {
      taskDescription.resignFirstResponder()
    }
    return true
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    taskDescription.resignFirstResponder()
    taskTitleText.resignFirstResponder()
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! PickerTableViewController
    //delegate call
    
    destinationVC.pickerTableViewDelegate = self

      destinationVC.provideUpdatedCollection(of: pickerViewRelationshipType, for: task, within: self.activeDataSet)

  }
}

