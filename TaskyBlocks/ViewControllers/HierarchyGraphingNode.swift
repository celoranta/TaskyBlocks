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
  var originXOffsetFromParent: CGFloat = 0.0
  
  var widthFactor: CGFloat = 1
  var width: CGFloat = 0

  
  override var description: String {
    var descriptionString = ""
    descriptionString.append("\n\n--Hierarchy graphing Node for '\(task.title)--'")
    descriptionString.append("\nParents: ")
    if parents.count == 0 {
      descriptionString.append("<none>")
    }
    for parent in parents {
      descriptionString.append("\n-\(parent.task.title)")
    }
    descriptionString.append("\nChildren: ")
    if children.count == 0 {
      descriptionString.append("<none>")
    }
    for child in children {
      descriptionString.append("\n-\(child.task.title)")
    }
    descriptionString.append("\nSibling paths:")
    if siblingPaths.count == 0 {
      descriptionString.append("<none>")
    }
    else {
      for path in siblingPaths {
        descriptionString.append("\n-\(path.parent!.task.title): \(path.siblingIndex)")
      }
    }



   //   descriptionString.append("\n-\(siblingPaths)")
    descriptionString.append("\nOrigin X Factor: \(originXFactor)")
        descriptionString.append("\nOrigin Y Factor: \(originYFactor)")
        descriptionString.append("\nWidth Factor: \(widthFactor)")
    descriptionString.append("\nWidth: \(width)\n")
    return descriptionString
  }
  
  init(task: TaskyNode) {
    self.task = task
  }
  
}
