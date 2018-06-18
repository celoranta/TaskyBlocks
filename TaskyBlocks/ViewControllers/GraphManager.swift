//
//  GraphManager.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift


class GraphManager: NSObject {
  
  
  private let tasks: Results<Tasky> = TaskyEditor.sharedInstance.TaskDatabase
  private var nodes: [TaskyNode] = []
  private var collapsedHierarchies: [TaskyNode] = []
  private var hierarchyGraph: [AnyObject] = []
  
  func node(for path: IndexPath) -> TaskyNode? /*Needs to return a node, not a cell*/ {
    return nil
  }
  
  func createHierarchyGraph() {
    let primalTasks = TaskyEditor.sharedInstance.TaskDatabase.filter("parents.@count = 0")
    
    //Add primal nodes to nodes array
    for task in primalTasks {
      nodes.append(TaskyNode.init(fromTask: task, fromParent: nil))
    }
    
    //
    chartDescendants(ofNodes: nodes)
    print(nodes)
  }
  
  //Sends an array of nodes to recursive node creation function
  fileprivate func chartDescendants(ofNodes nodeArray: [TaskyNode]) {
    for node in nodeArray {
      chartChildren(ofNode: node)
    }
  }
  
  
  //Creates a tree of nodes
  fileprivate func chartChildren(ofNode node: TaskyNode) {
    if node.task.children.count == 0 { return }
      for child in node.task.children {
        let newNode = TaskyNode.init(fromTask: child, fromParent: node.task)
        nodes.append(newNode)
        chartChildren(ofNode: newNode)
      }
    }
  
  //  //task(at path: IndexPath) should be unnecessary, as a NODE will be at an index path, and that contains a cell; so use node(for path: IndexPath) -> node
  //  func task(at path: IndexPath) -> Tasky {
  //   let placeholderTask = TaskyEditor.sharedInstance.newTask()
  //    return placeholderTask
  //  }
}
