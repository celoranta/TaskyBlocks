//
//  PickerTableViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-07.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class PickerTableViewController: UITableViewController {
  
  var superSet: [TaskyNode]?
  var subSet: [TaskyNode]?
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    //Test Data
    let testNodeA = TaskyNode()
    let testNodeB = TaskyNode()
    let testNodeC = TaskyNode()
    testNodeA.title = "First Task"
    testNodeB.title = "Second Task"
    testNodeC.title = "Third Task"
    
    self.superSet = [testNodeA, testNodeB, testNodeC]
    self.subSet = [testNodeA]
    
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
    guard let unwrappedMasterActiveTaskSet = self.superSet,
      let unwrappedParentsTaskSet = self.subSet
    else
    {
      fatalError("Fatal Error: data not loaded")
    }
    var rowQty: Int
    switch section
    {
    case 0: rowQty = unwrappedParentsTaskSet.count
    case 1: rowQty = unwrappedMasterActiveTaskSet.count
    default:
      rowQty = 0
    }
    return rowQty
  }
  
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
   let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! PickerTableViewCell
    if indexPath.section == 0
    {
      let task = subSet![indexPath.row]
      cell.checkMarkButton.setTitle("\u{2514}", for: .normal)
      cell.taskTitleLabel.text = task.title
    }
    return cell
  }

   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
  
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
  
  
  
}
