//
//  FinalPriorityViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-17.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class FinalPriorityViewController: MasterGraphingViewController
{
  override func viewDidLoad()
  {
    self.customLayout = FinalPriorityCollectionViewLayout()
    nextViewController = PomodoroViewController()
    customLayout.delegate = self
    self.nextViewControllerId = "pomodoroViewController"
    super.viewDidLoad()
    self.title = "Set Priority"
  }
  
  override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
  {
    print("drag began at \(sourceIndexPath) and ended at \(destinationIndexPath)")
    //currentDataModel.insert(currentDataModel.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
    let task1 = currentDataModel[destinationIndexPath.row]
    let task2 = currentDataModel[destinationIndexPath.row - 1]
    let meanAverage = (task1.priorityApparent + task2.priorityApparent) * 0.5
    let editedTask = currentDataModel[sourceIndexPath.row]
    TaskyNodeEditor.sharedInstance.updatePriorityDirect(of: editedTask, to: meanAverage)
    
  }
}
