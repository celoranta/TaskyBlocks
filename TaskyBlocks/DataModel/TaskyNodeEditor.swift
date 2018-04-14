//
//  TaskyNodeEditor.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-14.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class TaskyNodeEditor: NSObject {


  private let realm: Realm
  let database: Results<TaskyNode>
  static let sharedInstance = TaskyNodeEditor()

  //MARK: Task Creation
  func newTask() -> TaskyNode
  {
    let newTaskyNode = TaskyNode()
    realm.add(newTaskyNode)
    self.saveChanges()
    guard let returnedTask = realm.object(ofType: TaskyNode.self, forPrimaryKey: newTaskyNode.taskId)
      else
    {
      fatalError("Realm returned a non-task object")
    }
    return returnedTask
  }
  
  func complete(task: TaskyNode)
  {
    if task.isPermanent != 1
    {
    task.completionDate = Date()
    saveChanges()
    print("Tasky node \(task.title) with id: \(task.taskId) was marked complete")
    }
    else
    {
      print("Tasky node \(task.title) with id: \(task.taskId) is permanent and cannot be marked complete")
    }
  }
  
  //MARK: Write session management
  private func saveChanges()
  {
    try! realm.commitWrite()
    print("Write session committed")
    realm.beginWrite()
    print("New write session opened")
    // call update priorities here
  }
  
  private func abandonChanges()
  {
    realm.cancelWrite()
    print("Write session abandoned")
    realm.beginWrite()
    print("New write session opened")
  }
  
  //MARK: Initializers
  override private init()
  {
    var i = 0
    var newRealmInstanceAttempt: Realm? = nil
    var realmInstance: Realm!
    print("\n")
    while realmInstance == nil
    {
      i += 1
      print("Connecting to realm...  Attempt #\(i)")
      newRealmInstanceAttempt = try! Realm()
      if let uNewRealmDistance = newRealmInstanceAttempt
      {
        realmInstance = uNewRealmDistance
      }
      guard i < 10
        else
      {
      fatalError("Fatal Error:  Could not connect to realm")
      }
    }
    self.realm = realmInstance
    print("Realm instance created")
    self.database = realm.objects(TaskyNode.self)
    print("Database created in memory")
    super.init()
    realm.beginWrite()
    print("New write session begun")
  }

  
  deinit
  {
    try! realm.commitWrite()
    print("editor deinitialization:")
    print("Saved changes and closed write session")
    print("Realm instance closed")
  }
}
