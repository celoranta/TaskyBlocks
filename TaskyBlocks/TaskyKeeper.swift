//
//  TaskyKeeper.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-29.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit


class TaskyKeeper: NSObject {
  
  var activeTaskySet: Set<TaskyNode> = []
  
  enum relative
  {
    case ancestors, descendants, brethren
  }
  
  enum relationalScheme
  {
    case all, mostDistant, immediate
  }
  
  enum relationErrors
  {
    case selfReference
  }
  
  func crucials() -> (Set<TaskyNode>)
  {
    var crucials: Set<TaskyNode> = []
    for taskyNode in activeTaskySet
    {
      if taskyNode.priorityApparent > 66
      {
        crucials.insert(taskyNode)
      }
    }
    return crucials
  }
  
  func primals() -> (Set<TaskyNode>)
  {
    var primals: Set<TaskyNode> = []
    for taskyNode in activeTaskySet
    {
      if taskyNode.parents.isEmpty == true
      {
        primals.insert(taskyNode)
      }
    }
    return primals
  }
  
  override init()
  {
    super.init()
    let nodeA = TaskyNode()
    let nodeB = TaskyNode()
    let nodeC = TaskyNode()
    let nodeD = TaskyNode()
    let nodeE = TaskyNode()
    let nodeF = TaskyNode()
    let nodeG = TaskyNode()
    let nodeH = TaskyNode()
    let nodeI = TaskyNode()
    let nodeJ = TaskyNode()
    let nodeK = TaskyNode()
    let nodeL = TaskyNode()
    nodeD.parents.insert(nodeA, at: 0)
    activeTaskySet.insert(nodeA)
    activeTaskySet.insert(nodeB)
    activeTaskySet.insert(nodeC)
    activeTaskySet.insert(nodeD)
    activeTaskySet.insert(nodeE)
    activeTaskySet.insert(nodeF)
    activeTaskySet.insert(nodeG)
    activeTaskySet.insert(nodeH)
    activeTaskySet.insert(nodeI)
    activeTaskySet.insert(nodeJ)
    activeTaskySet.insert(nodeK)
    activeTaskySet.insert(nodeL)
    for task in activeTaskySet
    {
      task.priorityOverride = Double(arc4random_uniform(99) + 1)
      nodeK.priorityOverride = nodeA.priorityOverride
      nodeB.priorityOverride = nodeC.priorityOverride
    }
    
    TaskyNode.updatePriorityFor(tasks: activeTaskySet, limit: 100)
  }
  
  
  //  func collect(relatives:relative, ofTask:TaskyNode ofType:relationalScheme) throws -> Set<TaskyNode>
  //  {
  //    var thisTask = ofTask
  //    var allRelatives: Set<TaskyNode> = []
  //    for task in thisTask.parents
  //    {
  //      for parent in thisTask.parents
  //    }
  //    else
  //    {
  //      return
  //    }
  //    let dummyset: Set <TaskyNode> = []
  //    return dummyset
  //  }
  
  
}
