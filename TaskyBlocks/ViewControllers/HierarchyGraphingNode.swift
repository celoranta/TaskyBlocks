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

  //This class is currently set up to allow mutation of properties from management objects.  If possible, this should be refactored to use more stateless methods
class HierarchyGraphingNode: NSObject {
  
  let task: TaskyNode
  var title: String {
    return task.title
  }
  var parents: [HierarchyGraphingNode] = []
  var children: [HierarchyGraphingNode] = []
  var siblingPaths: [SiblingPath] = []
  var childXPositionRegister: CGFloat = 0.0
  
  //var originXFactor: CGFloat = 0.0
  var originYFactor: CGFloat = 0.0
  var originXOffsetFromParent: CGFloat = 0.0
  var originXFinal: CGFloat = 0.0
  
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
    descriptionString.append("\nOrigin X Final: \(originXFinal)")
        descriptionString.append("\nOrigin Y Factor: \(originYFactor)")
        descriptionString.append("\nWidth Factor: \(widthFactor)")
    descriptionString.append("\nWidth: \(width)\n")
    return descriptionString
  }
  
  func assignIndicesToChildren() {
    var indexRegister: CGFloat = 0.0
    for child in children {
      let newSiblingPath = SiblingPath.init(parent: self, siblingIndex: indexRegister)
      child.siblingPaths.append(newSiblingPath)
      indexRegister += 1
    }
  }
  
  init(task: TaskyNode, parent: HierarchyGraphingNode?) {
    self.task = task
  }
  
}
