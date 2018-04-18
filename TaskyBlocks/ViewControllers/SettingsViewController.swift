//
//  SettingsViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-17.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
  let settings = UserDefaults()
  @IBOutlet weak var randomTasksSwitch: UISwitch!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    let randomTasksOptionStatus = settings.bool(forKey: "NewTasksAreRandom")
    randomTasksSwitch.isOn = randomTasksOptionStatus
  }
  
  @IBAction func randomTasksSwitchThrown(_ sender: Any)
  {
    settings.set(randomTasksSwitch.isOn, forKey: "NewTasksAreRandom")
  }
}
