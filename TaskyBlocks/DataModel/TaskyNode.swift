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

  

  init(fromTask task: Tasky, fromParent parent: TaskyNode?) {
    self.task = task
    self.parent = parent
  }
  
  fileprivate func countDegrees(forNode node: TaskyNode) -> Int {
    if node.parent == nil {
      return 0
    }
    guard let unwrappedParent = parent
      else {
        fatalError("Error: ; non-nil parent node returned as nil")
    }
    return 1 + countDegrees(forNode:unwrappedParent)
  }
  
}

 
