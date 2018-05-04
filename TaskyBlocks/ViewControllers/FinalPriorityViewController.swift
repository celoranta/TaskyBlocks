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
    super.viewDidLoad()
    self.nextViewControllerId = "comboViewController"
    self.title = "Set Priority"
    self.includesAddBlock = false
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
  {
    print("drag began at \(sourceIndexPath) and ended at \(destinationIndexPath)")
    let draggedTask = currentDataModel[sourceIndexPath.row]
    var dragDirection: Direction = .up
    if sourceIndexPath < destinationIndexPath {dragDirection = .down}
    var taskWithNextGreaterPriority: TaskyNode? = nil
    var taskWithNextLesserPriority: TaskyNode? = nil
    switch dragDirection
    {
    case .up:
      if destinationIndexPath.row == 0 {}
      else
      {
        taskWithNextGreaterPriority = currentDataModel[destinationIndexPath.row - 1]
      }
      taskWithNextLesserPriority = currentDataModel[destinationIndexPath.row]
    case .down:
      if destinationIndexPath.row == currentDataModel.count - 1 {}
      else
      {
        taskWithNextLesserPriority = currentDataModel[destinationIndexPath.row + 1]
      }
      taskWithNextGreaterPriority = currentDataModel[destinationIndexPath.row]
    }
    print("Dragged \(draggedTask.title) \(dragDirection.rawValue) to space between \((taskWithNextLesserPriority?.title ?? "Bottom")) and \((taskWithNextGreaterPriority?.title ?? "Top"))")
    let nextGreaterPriority = taskWithNextGreaterPriority?.priorityApparent ?? 100
    let nextLesserPriority = taskWithNextLesserPriority?.priorityApparent ?? 0
    let averagedPriority = 0.5 * (nextLesserPriority + nextGreaterPriority)

    print("Next Gretater Priority = \(nextGreaterPriority)")
    print("Next Lesser Priority = \(nextLesserPriority)")
    print("New Priority is: \(averagedPriority)")
    TaskyNodeEditor.sharedInstance.setDirectPriority(of: draggedTask, to: averagedPriority, withoutUpdating: notificationToken)
    //sleep(2)
        currentDataModel = currentDataModel.sorted(by: { $0.priorityApparent > $1.priorityApparent})
    collectionView.reloadData()
    customLayout.invalidateLayout()
  }
}

