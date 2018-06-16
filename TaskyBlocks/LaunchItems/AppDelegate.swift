//
//  AppDelegate.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-26.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    initialAppSetup()

    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  fileprivate func initialAppSetup() {
    if TaskyEditor.sharedInstance.database.count == 0
    {
      let testNewTask = TaskyEditor.sharedInstance.newTask()
      TaskyEditor.sharedInstance.makePermanent(task: testNewTask)
      TaskyEditor.sharedInstance.changeTitle(task: testNewTask, to: "Be Happy")
      TaskyEditor.sharedInstance.setDirectPriority(of: testNewTask, to: 100.00)
      TaskyEditor.sharedInstance.setEstimatedTime(of: testNewTask, to: 10)
      TaskyEditor.sharedInstance.setElapsedTime(of: testNewTask, to: 5)
      TaskyEditor.sharedInstance.complete(task: testNewTask)
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
    userSettings.set(45, forKey: "DefaultSprintDuration")
  }


}

