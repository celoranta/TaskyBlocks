//
//  DetailViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

protocol TaskDetailDataSource
{
  func returnSelectedTask () -> TaskyNode
}

class DetailViewController: UIViewController, PickerTableViewDelegate, UITextViewDelegate, UITextFieldDelegate
{
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
  @IBOutlet weak var priorityDirectText: UITextField!
  @IBOutlet weak var completedSwitch: UISwitch!
  
  //MARK: Variables
  var task:TaskyNode!
  var taskDetailDataSource: TaskDetailDataSource!
  var pickerTableViewController: PickerTableViewController!
  var pickerViewRelationshipType: TaskRelationship!
  var taskDescriptionString: String?
  
  //Realm
  let realm = try! Realm()
  var activeDataSet: Results<TaskyNode>!
  var notificationToken: NotificationToken? = nil
  var detailViewController: DetailViewController? = nil
  
  //MARK: Methods
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    priorityDirectText.clearsOnBeginEditing = true
    priorityDirectText.keyboardType = .decimalPad
    taskTitleText.clearsOnBeginEditing = true
    taskDescription.autocapitalizationType = .sentences
    taskDescription.enablesReturnKeyAutomatically = true
    taskDescription.returnKeyType = .done
    taskDescription.delegate = self
    taskDescription.text = task.taskDescription
    let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    taskDescription.layer.borderWidth = 0.5
    taskDescription.layer.borderColor = borderColor.cgColor
    taskDescription.layer.cornerRadius = 5.0
    taskTitleText.delegate = self
    self.navigationItem.rightBarButtonItem = nil ;
    guard taskDetailDataSource != nil
      else
    {
      fatalError("No data source set for detail view")
    }
    task = taskDetailDataSource.returnSelectedTask()
    subscribeToNotifications()
    self.refreshView()

  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    if task.isPermanent == 1
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
  @IBAction func backButton(_ sender: Any)
  {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func addButton(_ sender: Any)
  {
    task = TaskyNodeEditor.sharedInstance.newTask()
    self.refreshView()
  }
  
  @IBAction func completedSwitchThrown(_ sender: Any)
  {
    TaskyNodeEditor.sharedInstance.complete(task: task)
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
    if let uPriorityDirect = task.priorityDirect.value
    {
      self.priorityDirectText.text = "\(uPriorityDirect)"
    }
    else
    {
      self.priorityDirectText.text = "<not set>"
    }
    self.taskTitleText.text = task.title
    self.taskTitleText.enablesReturnKeyAutomatically = true
    self.uuidLabel.text = task.taskId
    let roundedPriority = round(task.priorityApparent)
    self.priorityLevelLabel.text = roundedPriority.description
    self.isPrimalStatusLabel.text = task.isPrimal.description
    self.isActionableStatusLabel.text = task.isActionable.description
    let dateString = DateFormatter.localizedString(from: task.taskDate, dateStyle: .medium, timeStyle: .short)
    self.taskDateLabel.text = dateString
    self.completedSwitch.isOn = task.completionDate != nil
    
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
    parentsListButton.setTitleColor(UIColor.black, for: .normal)
    childrenListButton.setTitle(childrenString, for: .normal)
    childrenListButton.setTitleColor(UIColor.black, for: .normal)
    dependentsListButton.setTitle(consequentString, for: .normal)
    dependentsListButton.setTitleColor(UIColor.black, for: .normal)
    dependeesListButton.setTitle(antecedentString, for: .normal)
    dependeesListButton.setTitleColor(UIColor.black, for: .normal)
  }
  
  //MARK: PickerTableView Delegate
  func retrieveUpdatedCollection(from table: PickerTableViewController)
  {
    let returnPickerData = table.postUpdatedTaskSubcollection()
    switch returnPickerData.relationship
    {
    case .parents:
      TaskyNodeEditor.sharedInstance.removeAsChildToAllParents(task: task)
      for parent in returnPickerData.collection
      {
        TaskyNodeEditor.sharedInstance.add(task: task, AsChildTo: parent)
      }
      print("picker returned parents")
    case .children:
      print("picker returned children")
      TaskyNodeEditor.sharedInstance.removeAsParentToAllChildren(task: task)
      for child in returnPickerData.collection
      {
        TaskyNodeEditor.sharedInstance.add(task: task, asParentTo: child)
        
      }
    case .dependents:
      TaskyNodeEditor.sharedInstance.removeAsAntecedentToAll(task: task)
      for consequent in returnPickerData.collection
      {
        TaskyNodeEditor.sharedInstance.add(task: task, asAntecedentTo: consequent)
      }
      print("picker returned dependents")
      
    case .dependees:
      TaskyNodeEditor.sharedInstance.removeAsConsequentToAll(task: task)
      for antecedent in returnPickerData.collection
      {
        TaskyNodeEditor.sharedInstance.add(task: task, asConsequentTo: antecedent)
      }
      print("picker returned dependees")
      
    }
    refreshView()
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
  {
    if textField == priorityDirectText
    {
      switch string
      {
      case "0","1","2","3","4","5","6","7","8","9":
        return true
      case ".":
        let array = Array(priorityDirectText.text!)
        var decimalCount = 0
        for character in array
        {
          if character == "."
          {
            decimalCount += 1
          }
        }
        if decimalCount == 1
        {
          return false
        } else
        {
          return true
        }
      default:
        let array = Array(string)
        if array.count == 0
        {
          return true
        }
        return false
      }
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    taskTitleText.resignFirstResponder()
    priorityDirectText.resignFirstResponder()
    refreshView()
    return true
  }
  func textFieldDidEndEditing(_ textField: UITextField)
  {
    if textField == priorityDirectText
    {
      if let unwrappedText = priorityDirectText.text
      {
        TaskyNodeEditor.sharedInstance.setDirectPriority(of: task, to: ((unwrappedText as NSString).doubleValue))
      }
      priorityDirectText.resignFirstResponder()
    }
    else
    {
      let inputString = textField.text ?? ""
      TaskyNodeEditor.sharedInstance.changeTitle(task: task, to: inputString)
    }
    refreshView()
  }
  
  func textViewDidEndEditing(_ textView: UITextView)
  {
    print("Called textViewDidEndEditing")


      let taskDescriptionString = taskDescription.text ?? ""
      TaskyNodeEditor.sharedInstance.updateTaskDescription(for: task, with: taskDescriptionString)
      taskDescription.resignFirstResponder()
      refreshView()

  }
  
  func textViewDidChange(_ textView: UITextView) {
    print("Called textViewDidChange")
    
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    super.touchesBegan(touches, with: event)
    taskDescription.resignFirstResponder()
    taskTitleText.resignFirstResponder()
    priorityDirectText.resignFirstResponder()
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    let destinationVC = segue.destination as! PickerTableViewController
    destinationVC.pickerTableViewDelegate = self
    let predicate = NSPredicate.init(format: "completionDate == nil AND taskId != %@",self.task.taskId)
    destinationVC.provideUpdatedCollection(of: pickerViewRelationshipType, for: task, within: TaskyNodeEditor.sharedInstance.database.filter(predicate))
  }
  
  //MARK: Realm Notifications
  fileprivate func subscribeToNotifications()
  {
    let filter = NSPredicate.init(format: "taskId == %@", self.task.taskId)
    let results = realm.objects(TaskyNode.self).filter(filter)
    task = results[0]
    detailViewController = self
    notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
      guard let detailViewController = self?.detailViewController else
      {
        return
      }
      switch changes
      {
      case .initial:
        print("Initial")
      case . update:
        print("Update")
        detailViewController.refreshView()
      case .error(let error):
        print(error)
      }
    }
  }
}
