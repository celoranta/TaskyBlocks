//
//  FinalDependenceViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-17.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class FinalDependenceViewController: MasterGraphingViewController
{
  override func viewDidLoad()
  {
    filter = "completionDate == nil"
    customLayout = FinalDependenceCollectionViewLayout()
    nextViewController = FinalPriorityViewController()
    super.viewDidLoad()
    self.title = "Set Dependence"
  }
}
