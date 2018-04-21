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

  override func setupNextVC(vc: MasterGraphingViewController)
  {
    vc.filter = "completionDate == nil"
    vc.customLayout = FinalDependenceCollectionViewLayout()
  }
}
