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

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  
  
  var task:TaskyNode!
  var taskDetailDataSource: TaskDetailDataSource!
  var detailDataSource: [String]!
  
  @IBOutlet weak var taskTitleText: UITextField!
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
    self.taskTitleText.text = task.title
    self.taskDescription.text = task.taskDescription
    self.uuidLabel.text = task.taskId
    detailDataSource = self.createDetailTable()
    
    // Do any additional setup after loading the view.
  }
  
  //MARK: Tableview Data Source Methods:
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return detailDataSource.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
  }
  
  //MARK: Tableview Delegate Methods:
  func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> UITableViewCell
  {
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func backButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func createDetailTable() -> ([String])
  {
    let detailTable =
    [
      "Parents",
      "Children",
      "Dependents",
      "Dependees",
      "Values Served",
      "Tasks Comprised Of",
      
    ]
    return detailTable
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
