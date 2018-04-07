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
  
  @IBOutlet weak var taskTitle: UILabel!
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var taskDescription: UITextView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard taskDetailDataSource != nil
      else
    {
      fatalError("No data source set for detail view")
    }
    let task = taskDetailDataSource.returnSelectedTask()
    self.taskTitle.text = task.title
    self.taskDescription.text = task.description
    self.uuidLabel.text = task.taskId
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
