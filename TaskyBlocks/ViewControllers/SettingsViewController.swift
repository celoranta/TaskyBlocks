//
//  SettingsViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-17.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

  let settings = UserDefaults()
  
  @IBOutlet weak var randomTasksSwitch: UISwitch!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  override func viewWillAppear(_ animated: Bool) {
   let randomTasksOptionStatus = settings.bool(forKey: "NewTasksAreRandom")
    randomTasksSwitch.isOn = randomTasksOptionStatus
  }
    
  @IBAction func randomTasksSwitchThrown(_ sender: Any) {
    settings.set(randomTasksSwitch.isOn, forKey: "NewTasksAreRandom")
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  

  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
