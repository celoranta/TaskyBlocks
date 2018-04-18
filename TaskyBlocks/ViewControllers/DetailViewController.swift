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

class DetailViewController: UIViewController, PickerTableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UITextInputTraits {

  
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
  var taskDescriptionString: String?
 
  //Realm
  var realm: Realm!
  var activeDataSet: Set<TaskyNode>!
  
  //MARK: Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    priorityDirectText.clearsOnBeginEditing = true
    priorityDirectText.keyboardType = .decimalPad
    taskTitleText.clearsOnBeginEditing = true
    taskDescription.autocapitalizationType = .sentences
    taskDescription.enablesReturnKeyAutomatically = true
    taskDescription.returnKeyType = .done
    
//    try! realm = Realm()
    let tasks = TaskyNodeEditor.sharedInstance.database
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
  @IBAction func backButton(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  @IBAction func addButton(_ sender: Any) {
    task = TaskyNodeEditor.sharedInstance.newTask()
    self.refreshView()
  }
  @IBAction func deleteButton(_ sender: Any) {
    
  }
  @IBAction func completedSwitchThrown(_ sender: Any) {

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
    self.priorityDirectText.clearsOnBeginEditing = true
    self.priorityDirectText.keyboardType = .decimalPad
    if let uPriorityDirect = task.priorityDirect.value
    { self.priorityDirectText.text = "\(uPriorityDirect)"
    }
    else
    { self.priorityDirectText.text = "<not set>"
    }
    self.taskTitleText.text = task.title
    self.taskTitleText.enablesReturnKeyAutomatically = true
    self.taskDescription.placeholder = "please enter a description"
    //self.taskDescription.text = task.taskDescription
    self.uuidLabel.text = task.taskId
    self.priorityLevelLabel.text = task.priorityApparent.description
    self.isPrimalStatusLabel.text = task.isPrimal.description
    self.isActionableStatusLabel.text = task.isActionable.description
    self.taskDateLabel.text = task.taskDate.description
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
    childrenListButton.setTitle(childrenString, for: .normal)
    dependentsListButton.setTitle(consequentString, for: .normal)
    dependeesListButton.setTitle(antecedentString, for: .normal)
   // DISABLED deleteButton.isEnabled = tasksData.serveTaskData().count > 1
  }
  
  //MARK: PickerTableView Delegate
  
  
  func retrieveUpdatedCollection(from table: PickerTableViewController)
  {
   // realm.beginWrite()
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
    //try! realm.commitWrite()
    refreshView()
  }
  
  //MARK: Text Field Delegate
//  func textFieldDidBeginEditing(_ textField: UITextField) {
//    if textField == taskTitleText
//    {
//      textField.clearsOnBeginEditing = true
//    }
//    if textField == priorityDirectText
//    {
//      textField.clearsOnBeginEditing = true
//    }
//  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == taskTitleText
    {
      let inputString = textField.text ?? ""
      TaskyNodeEditor.sharedInstance.changeTitle(task: task, to: inputString)

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
  
  //MARK: Text View Delegate
  
  
//  func textViewDidChange(_ textView: UITextView) {
//    if textView == taskDescription
//    {
//      let inputString = textView.text ?? ""
//      taskDescriptionString = inputString
//    }
//  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView == taskDescription
    {
      let taskDescriptionString = textView.text ?? ""
      TaskyNodeEditor.sharedInstance.updateTaskDescription(for: task, with: taskDescriptionString)
      taskDescription.resignFirstResponder()
      refreshView()
    }
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


////
//// UIKeyboardType
////
//// Requests that a particular keyboard type be displayed when a text widget
//// becomes first responder.
//// Note: Some keyboard/input methods types may not support every variant.
//// In such cases, the input method will make a best effort to find a close
//// match to the requested type (e.g. displaying UIKeyboardTypeNumbersAndPunctuation
//// type if UIKeyboardTypeNumberPad is not supported).
////
//public enum UIKeyboardType : Int {
//
//
//  case `default` // Default type for the current input method.
//
//  case asciiCapable // Displays a keyboard which can enter ASCII characters
//
//  case numbersAndPunctuation // Numbers and assorted punctuation.
//
//  case URL // A type optimized for URL entry (shows . / .com prominently).
//
//  case numberPad // A number pad with locale-appropriate digits (0-9, ۰-۹, ०-९, etc.). Suitable for PIN entry.
//
//  case phonePad // A phone pad (1-9, *, 0, #, with letters under the numbers).
//
//  case namePhonePad // A type optimized for entering a person's name or phone number.
//
//  case emailAddress // A type optimized for multiple email address entry (shows space @ . prominently).
//
//  @available(iOS 4.1, *)
//  case decimalPad // A number pad with a decimal point.
//
//  @available(iOS 5.0, *)
//  case twitter // A type optimized for twitter text entry (easy access to @ #)
//
//  @available(iOS 7.0, *)
//  case webSearch // A default keyboard type with URL-oriented addition (shows space . prominently).
//
//  @available(iOS 10.0, *)
//  case asciiCapableNumberPad // A number pad (0-9) that will always be ASCII digits.
//
//
//  public static var alphabet: UIKeyboardType { get } // Deprecated
//}
//
////
//// UIKeyboardAppearance
////
//// Requests a keyboard appearance be used when a text widget
//// becomes first responder..
//// Note: Some keyboard/input methods types may not support every variant.
//// In such cases, the input method will make a best effort to find a close
//// match to the requested type.
////
//public enum UIKeyboardAppearance : Int {
//
//
//  case `default` // Default apperance for the current input method.
//
//  @available(iOS 7.0, *)
//  case dark
//
//  @available(iOS 7.0, *)
//  case light
//
//  public static var alert: UIKeyboardAppearance { get } // Deprecated
//}
//
////
//// UIReturnKeyType
////
//// Controls the display of the return key.
////
//// Note: This enum is under discussion and may be replaced with a
//// different implementation.
////
//public enum UIReturnKeyType : Int {
//
//
//  case `default`
//
//  case go
//
//  case google
//
//  case join
//
//  case next
//
//  case route
//
//  case search
//
//  case send
//
//  case yahoo
//
//  case done
//
//  case emergencyCall
//
//  @available(iOS 9.0, *)
//  case `continue`
//}
//
//public struct UITextContentType : Hashable, Equatable, RawRepresentable {
//
//  public init(_ rawValue: String)
//
//  public init(rawValue: String)
//}
//
////
//// UITextInputTraits
////
//// Controls features of text widgets (or other custom objects that might wish
//// to respond to keyboard input).
////
//public protocol UITextInputTraits : NSObjectProtocol {
//
//
//  optional public var autocapitalizationType: UITextAutocapitalizationType { get set } // default is UITextAutocapitalizationTypeSentences
//
//  optional public var autocorrectionType: UITextAutocorrectionType { get set } // default is UITextAutocorrectionTypeDefault
//
//  @available(iOS 5.0, *)
//  optional public var spellCheckingType: UITextSpellCheckingType { get set } // default is UITextSpellCheckingTypeDefault;
//
//  @available(iOS 11.0, *)
//  optional public var smartQuotesType: UITextSmartQuotesType { get set } // default is UITextSmartQuotesTypeDefault;
//
//  @available(iOS 11.0, *)
//  optional public var smartDashesType: UITextSmartDashesType { get set } // default is UITextSmartDashesTypeDefault;
//
//  @available(iOS 11.0, *)
//  optional public var smartInsertDeleteType: UITextSmartInsertDeleteType { get set } // default is UITextSmartInsertDeleteTypeDefault;
//
//  optional public var keyboardType: UIKeyboardType { get set } // default is UIKeyboardTypeDefault
//
//  optional public var keyboardAppearance: UIKeyboardAppearance { get set } // default is UIKeyboardAppearanceDefault
//
//  optional public var returnKeyType: UIReturnKeyType { get set } // default is UIReturnKeyDefault (See note under UIReturnKeyType enum)
//
//  optional public var enablesReturnKeyAutomatically: Bool { get set } // default is NO (when YES, will automatically disable return key when text widget has zero-length contents, and will automatically enable when text widget has non-zero-length contents)
//
//  optional public var isSecureTextEntry: Bool { get set } // default is NO
//
//
//  // The textContentType property is to provide the keyboard with extra information about the semantic intent of the text document.
//  @available(iOS 10.0, *)
//  optional public var textContentType: UITextContentType! { get set } // default is nil
//}
