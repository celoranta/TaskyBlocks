//
//  TaskyNode.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class TaskyNode: NSObject {
  
  let task: Tasky
  let parent: TaskyNode?
  let nodeId = String(UUID().uuidString) + "N"
  var degree:Int {
   return countDegrees(forNode: self)
    }
  var tree: [Any?] = []
  var treePath: TreePath = []
  
  init(fromTask task: Tasky, fromTreePath treePath: TreePath, fromParent parent: TaskyNode?) {
    self.task = task
    self.parent = parent
    self.treePath = treePath
  }
  
  fileprivate func countDegrees(forNode node: TaskyNode) -> Int {
    if let parent = node.parent{
      return 1 + countDegrees(forNode: parent)
    }
    else {
      return 0
    }
  }
//    if node.parent == nil {
//      return 0
//    }
//    guard let unwrappedParent = parent
//      else {
//        fatalError("Error: ; non-nil parent node returned as nil")
//    }
//    return 1 + countDegrees(forNode:unwrappedParent)
//  }
  
}

 
