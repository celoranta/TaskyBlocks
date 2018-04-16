//
//  SplashViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-06.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class SplashViewController: UIViewController {
  var taskManager = TaskyNodeManager()
  
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    if TaskyNodeEditor.sharedInstance.database.count == 0
    {
      let testNewTask = TaskyNodeEditor.sharedInstance.newTask()
      
      TaskyNodeEditor.sharedInstance.makePermanent(task: testNewTask)
      TaskyNodeEditor.sharedInstance.changeTitle(task: testNewTask, to: "Be Happy")
      TaskyNodeEditor.sharedInstance.setDirectPriority(of: testNewTask, to: 100.00)
      TaskyNodeEditor.sharedInstance.complete(task: testNewTask)
      testNewTask.soundOff()
      let userSettings = UserDefaults()
      let settingsExist = userSettings.bool(forKey: "DefaultsPreviouslyLoaded")
      if settingsExist == false
      {
        self.loadUserDefaults()
      }
    }
  }
  
  fileprivate func loadUserDefaults() {
    let userSettings = UserDefaults()
    userSettings.set(false, forKey: "NewTasksAreRandom")
    userSettings.set(true, forKey: "DefaultsPreviouslyLoaded")
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
