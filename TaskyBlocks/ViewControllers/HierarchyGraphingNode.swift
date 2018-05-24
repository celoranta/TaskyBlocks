//
//  HierarchyGraphingNode.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-16.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

struct SiblingPath {
  var parent: HierarchyGraphingNode? = nil
  var siblingIndex: CGFloat? = nil
}

class HierarchyGraphingNode: NSObject {
  
  let task: TaskyNode
  var parents: [HierarchyGraphingNode] = []
  var children: [HierarchyGraphingNode] = []
  var siblingPaths: [SiblingPath] = []
  
  var originXFactor: CGFloat = 0.0
  var originYFactor: CGFloat = 0.0
  var widthFactor: CGFloat = 1
  
  init(task: TaskyNode) {
    self.task = task
  }
}
