//
//  FinalHierarchyViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class FinalHierarchyViewController: MasterGraphingViewController {

  override func viewDidLoad() {
    
    filter = "completionDate == nil"
    
    customLayout = HierarchyCollectionViewLayout()
   // collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: customLayout)
    nextViewController = FinalDependenceViewController()
    
//    let sortedData = Array(activeTaskySet.sorted(byKeyPath: "apparentPriority", ascending: true))
    super.viewDidLoad()
    self.title = "Set Hierarchy"
//    for task in sortedData
//    {
//      task.soundOff()
//    }

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
  {
    //set cell height here
    return CGFloat(blockyHeight)
  }
  
  //MARK: Actions
  @IBAction func addButton(_ sender: Any)
  {
    let userSettings = UserDefaults()
    let random = userSettings.bool(forKey: "NewTasksAreRandom")
    switch random
    {
    case false:
      _ = TaskyNodeEditor.sharedInstance.newTask()
    case true:
      _ = TaskyNodeEditor.sharedInstance.createRandomTasks(qty: 1)
    }
    let dataset = Set.init(TaskyNodeEditor.sharedInstance.database.filter(filter))
    //TaskyNodeEditor.sharedInstance.updatePriorityFor(tasks: Array(dataset), limit: 100)
    self.collectionView.reloadData()
  }
  
  //MARK: Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier
    {
    case "HierarchyToDetail":
      print("prepare for segue to detail with \(selectedTask.title) selected was called")
      let detailVC = segue.destination.childViewControllers.first as! DetailViewController
      detailVC.taskDetailDataSource = self as TaskDetailDataSource

    default:
      return
    }
  }
}
