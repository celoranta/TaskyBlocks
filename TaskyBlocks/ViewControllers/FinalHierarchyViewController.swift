//
//  FinalHierarchyViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class FinalHierarchyViewController: MasterGraphingViewController
{
  override func viewDidLoad()
  {

    super.viewDidLoad()
    nextViewController = FinalDependenceViewController()
    self.title = "Set Hierarchy"
    self.includesAddBlock = true
  }
  
  override func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
  {
    //set cell height here
    return CGFloat(blockyHeight)
  }
  
  //MARK: Actions

  
  //MARK: Segues
  
  override func setupNextVC(vc: MasterGraphingViewController)
  {
    vc.filter = "completionDate == nil"
    vc.customLayout = FinalDependenceCollectionViewLayout()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
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
