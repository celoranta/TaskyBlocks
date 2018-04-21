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
    // Move to dependency injection
    self.customLayout = FinalPriorityCollectionViewLayout()
    nextViewController = PomodoroViewController()
    
    //Should be first in section
    super.viewDidLoad()
    
    self.nextViewControllerId = "pomodoroViewController"
    self.title = "Set Priority"
    self.includesAddBlock = false
  }
  
  override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
  {
    var dragDirection: Direction = .none
    print("drag began at \(sourceIndexPath) and ended at \(destinationIndexPath)")
    let draggedTask = currentDataModel[sourceIndexPath.row]
    if sourceIndexPath > destinationIndexPath {dragDirection = .up}
    if sourceIndexPath < destinationIndexPath {dragDirection = .down}
    if sourceIndexPath == destinationIndexPath {dragDirection = .none}
    switch dragDirection
    {
    case .up:
      print("dragged item \(dragDirection)")
      let taskWithNextGreaterPriority: TaskyNode? = currentDataModel[destinationIndexPath.row - 1]
      let taskWithNextLesserPriority: TaskyNode? = currentDataModel[destinationIndexPath.row ]
      print("Dragged \(draggedTask.title) to space between \((taskWithNextLesserPriority?.title ?? "Bottom")) and \((taskWithNextGreaterPriority?.title ?? "Top"))")
      let nextGreaterPriority = taskWithNextGreaterPriority?.priorityApparent ?? 100
      let nextLesserPriority = taskWithNextLesserPriority?.priorityApparent ?? 0
      let averagedPriority = 0.5 * (nextLesserPriority + nextGreaterPriority)
      
      print("Next Greater Priority = \(nextGreaterPriority)")
      print("Next Lesser Priority = \(nextLesserPriority)")
      print("New Priority is: \(averagedPriority)")
     TaskyNodeEditor.sharedInstance.setDirectPriority(of: draggedTask, to: averagedPriority)
    case .down:
            print("dragged item \(dragDirection)")
    case .none:
            print("dragged item \(dragDirection)")
    }
  }
}

