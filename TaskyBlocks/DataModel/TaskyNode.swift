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
  
  /*It seems that, generally speaking, the nodes should be transient, and only created just before graphing, with no plan to save them for further use.  However, there are a few factors which, although unrelated to actual task data, should nevertheless influence the layout of cells.  These include:
   isCollapsed:  It can apply to a task when shown under one parent, yet not apply to the same task when shown under another parent.  This needs to be saved between sessions and regraphings
   Sibling Order: It can apply to a task when shown under one parent, yet apply differently to the same task when shown under another parent.  This needs to be saved between sessions and regraphings.
   */

  
  let task: Tasky
  let parent: TaskyNode?
  let nodeId = String(UUID().uuidString) + "N"
  var degree:Int {
   return countDegrees(forNode: self)
    }
  var tree: [TaskyNode] = [] // Contains all descendant nodes, nested
  var treePath: TreePath = [] // Contains the sibling order index of this and all ancestor nodes
  var x: CGFloat = 0.0
  var y: CGFloat = 0.0
  var layoutAttribute: UICollectionViewLayoutAttributes!
  var isCollapsed = false //Records whether descendants should appear in graph
  
  init(fromTask task: Tasky, fromTreePath treePath: TreePath, fromParent parent: TaskyNode? = nil) {
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

 
