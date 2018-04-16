//
//  TaskyNodeManager.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-11.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift


class TaskyNodeManager: NSObject
  
{
  var realm: Realm!
  var tasks: Results<TaskyNode>!
  var beHappy: TaskyNode!
  var activeTaskySet: Set<TaskyNode>!
  let filter = "completionDate == nil"

  func setupProcesses()
  {
    var taskSet: Set<TaskyNode>!
    realm = try! Realm()
    activeTaskySet = Set.init(realm.objects(TaskyNode.self))
    tasks = realm.objects(TaskyNode.self)

    taskSet = Set(tasks)
    try! realm.write
    {
    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)  //Only works on QUERIED REALM OBJECTS
    }
//    TaskyBlockLibrary.realmEdit {
//      self.createRandomTasks()
//    }
    for task in taskSet
    { task.soundOff()
    }
  }

  
  func deleteAllHistory()
  {
    realm.deleteAll()
  }

  func updateAllTaskPriorities()
  {
    TaskyNode.updatePriorityFor(tasks: Set.init(realm.objects(TaskyNode.self)), limit: 100)  //Only works on QUERIED REALM OBJECTS
    for task in realm.objects(TaskyNode.self).filter(filter)
    { task.soundOff()
    }
  }
}



