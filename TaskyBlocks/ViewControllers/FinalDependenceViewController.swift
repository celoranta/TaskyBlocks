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


    super.viewDidLoad()
    
        nextViewController = FinalPriorityViewController()
    self.title = "Set Dependence"
    self.includesAddBlock = false
    
  }
  
  override func setupNextVC(vc: MasterGraphingViewController)
  {
    vc.filter = "completionDate == nil"
    vc.customLayout = FinalDependenceCollectionViewLayout()
  }
}
