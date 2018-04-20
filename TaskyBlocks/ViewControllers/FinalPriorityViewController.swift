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
}

