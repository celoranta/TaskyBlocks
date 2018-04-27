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
  
  fileprivate let initialDefaultSprintDurMin = 45.0
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    if TaskyNodeEditor.sharedInstance.database.count == 0
    {
      let testNewTask = TaskyNodeEditor.sharedInstance.newTask()
      TaskyNodeEditor.sharedInstance.makePermanent(task: testNewTask)
      TaskyNodeEditor.sharedInstance.changeTitle(task: testNewTask, to: "Be Happy")
      TaskyNodeEditor.sharedInstance.setDirectPriority(of: testNewTask, to: 100.00)
      TaskyNodeEditor.sharedInstance.setEstimatedTime(of: testNewTask, to: 10)
      TaskyNodeEditor.sharedInstance.setElapsedTime(of: testNewTask, to: 5)
      TaskyNodeEditor.sharedInstance.complete(task: testNewTask)
      print("\nNew primal value created: ")
      testNewTask.soundOff()
      
      let userSettings = UserDefaults()
      let settingsExist = userSettings.bool(forKey: "DefaultsPreviouslyLoaded")
      if settingsExist == false
      {
        self.configureInitialUserDefaults()
      }
    }
  }
  
  fileprivate func configureInitialUserDefaults()
  {
    let userSettings = UserDefaults()
    userSettings.set(false, forKey: "NewTasksAreRandom")
    userSettings.set(true, forKey: "DefaultsPreviouslyLoaded")
    userSettings.set(initialDefaultSprintDurMin, forKey: "DefaultSprintDuration")
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
  {
    performSegue(withIdentifier: "toHierarchy", sender: self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toHierarchy"
    {
      let nextNavCtrl = segue.destination as! UINavigationController
      let nextVC = nextNavCtrl.topViewController as! MasterGraphingViewController
      nextVC.filter = "completionDate ==nil"
      nextVC.customLayout = HierarchyCollectionViewLayout()
    }
  }
}
