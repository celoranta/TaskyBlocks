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

class DetailViewController: UIViewController {

  
  var task:TaskyNode!
  var taskDetailDataSource: TaskDetailDataSource!

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
  

  @IBAction func backButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  

  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
