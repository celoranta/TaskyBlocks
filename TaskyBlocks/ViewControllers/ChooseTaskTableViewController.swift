//
//  ChooseTaskTableViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-25.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol ChooseTask {
  func chosenTask(task: TaskyNode)
}


class ChooseTaskTableViewController: UITableViewController {
  
  var chooseTaskDelegate: ChooseTask!
  var availableTasks: [TaskyNode]!
  var selectedTask: TaskyNode!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print(availableTasks)
    guard availableTasks.count > 0
      else
    {
      self.dismiss(animated: true, completion: nil)
      return
    }
    self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return availableTasks.count
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    let task = availableTasks[indexPath.row]
    cell.textLabel?.text = task.title
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedTask = self.availableTasks[indexPath.row]
    self.chooseTaskDelegate.chosenTask(task: selectedTask)
    self.dismiss(animated: true, completion: nil)
    
  }
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
