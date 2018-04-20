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
    self.customLayout = FinalPriorityCollectionViewLayout()
    nextViewController = PomodoroViewController()
    customLayout.delegate = self
    self.nextViewControllerId = "pomodoroViewController"
    super.viewDidLoad()
    self.title = "Set Priority"
  }
  
//  override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
//  {
//    var dragDirection: Direction = .none
//    print("drag began at \(sourceIndexPath) and ended at \(destinationIndexPath)")
//    if sourceIndexPath > destinationIndexPath {dragDirection = .up}
//    if sourceIndexPath < destinationIndexPath {dragDirection = .down}
//    if sourceIndexPath == destinationIndexPath {dragDirection = .none}
//    switch dragDirection
//    {
//    case .up:
//      print("dragged item \(dragDirection)")
//    case .down:
//            print("dragged item \(dragDirection)")
//    case .none:
//            print("dragged item \(dragDirection)")
//    default:
//      fatalError("Drag direction defaulted")
//    }
//  }
}

