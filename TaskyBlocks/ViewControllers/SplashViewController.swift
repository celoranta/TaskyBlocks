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
  var realm: Realm!

    override func viewDidLoad() {
        super.viewDidLoad()
      taskManager.setupProcesses()
     if let navController = self.navigationController
     {
    
      let unwrappedViewControllers = navController.viewControllers
      if let unwrappedViewController = unwrappedViewControllers[0] as? ViewController
      {
        unwrappedViewController.tasksData = self.taskManager
      }
//      if let unwrappedViewController = unwrappedViewControllers[0] as? PomodoroViewController
//      {
//        unwrappedViewController.tasksData = self.taskManager
//      }
      
        // Do any additional setup after loading the view.
    }
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
