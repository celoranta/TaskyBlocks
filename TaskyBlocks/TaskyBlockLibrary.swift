//
//  TaskyBlockLibrary.swift
//  
//
//  Created by Chris Eloranta on 2018-04-11.
//

import Foundation


typealias TaskRecord = (taskId: String, priority: Double)

enum RelationType
{
  case parents, children, antecedents, consequents
}

protocol TaskDataSource
{
  var activeTaskySet: Set<TaskyNode>
  { get
    set
  }
  func serveTaskData() -> (Set<TaskyNode>)
  //func crucials() -> (Set<TaskyNode>)
  //func primals() -> (Set<TaskyNode>)
  //func newTask() -> TaskyNode
  //func remove(task: TaskyNode)
  //func setComplete(for task: TaskyNode, on date: Date)
}


