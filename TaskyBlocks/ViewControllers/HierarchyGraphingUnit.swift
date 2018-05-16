//
//  HierarchyGraphingUnit.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-16.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class HierarchyGraphingUnit: NSObject {

  let task: TaskyNode
  let defaultCellSize: CGSize
  var generation: Int {
    return countOlderGenerations(of: task)
  }
  var block: UIView? = nil
  var chunk: UIView? = nil
  var graphViewOffset: CGFloat = 0
  var children: [HierarchyGraphingUnit] = []
  var parents: [HierarchyGraphingUnit] = []
  var dominantGraphView: UIView? {
    get {
      if self.chunk != nil {return chunk}
      else if self.block != nil {return block}
      else {return nil}
    }
  }
  var blockWidth: CGFloat {
    get {
      var width: CGFloat = 0
      if !self.children.isEmpty {
        for child in children {
          width += child.blockWidth
        }
      }
      else {
        width = self.defaultCellSize.width
      }
      return width
    }
  }
  
  fileprivate func countOlderGenerations(of task: TaskyNode) -> Int {
    for parent in task.parents {
      return 1 + countOlderGenerations(of: parent)
    }
    return 0
  }


init(with task: TaskyNode, defaultCellSize: CGSize)
  {
    self.defaultCellSize = defaultCellSize
    self.task = task
  }
}
