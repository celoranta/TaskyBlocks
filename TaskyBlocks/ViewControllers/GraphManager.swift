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
  // Todo: Create collection of collapsed index paths
  private var hierarchyGraph: [AnyObject] = []
  
  func node(for path: IndexPath) -> TaskyNode? /*Needs to return a node, not a cell*/ {
    return nil
  }
  
  func createHierarchyGraph() {
    let rootTasks = TaskyEditor.sharedInstance.TaskDatabase.filter("parents.@count = 0")
    
    //Add root nodes to nodes array
    for task in rootTasks {
      nodes.append(TaskyNode.init(fromTask: task, fromParent: nil))
    }
    
    //Recurse children to create nodes for each node in forest
    chartDescendants(ofNodes: nodes)
    
    //Determine total number of generations
    var maxDegree: Int
    guard let nodeAtMaxGen = nodes.max(by: {$0.degree > $1.degree})
      else {
        fatalError("Error: No node with max degree found in hierarchy tree")
    }
     maxDegree = nodeAtMaxGen.degree

    //Package each generation of nodes into parents' tree property
    for generation in stride(from: maxDegree, to: 0, by: -1) {
      for node in nodes.filter({$0.degree == generation}) {
        guard let parent = node.parent
          else {
            fatalError("No parent found for node")
        }
        parent.tree.append(node)
      }
    }
    
    //Add packaged root nodes to the overall graph 'forest'
    hierarchyGraph = []
    for node in nodes.filter({$0.degree == 0}) {
      hierarchyGraph.append(node)
    }
    print(hierarchyGraph)
  }
  
  //Sends an array of nodes to recursive node creation function
  fileprivate func chartDescendants(ofNodes nodeArray: [TaskyNode]) {
    for node in nodeArray {
      chartChildren(ofNode: node)
    }
  }
  
  //Creates all nodes in hierarchy graph
  fileprivate func chartChildren(ofNode node: TaskyNode) {
    if node.task.children.count == 0 { return }
      for child in node.task.children {
        let newNode = TaskyNode.init(fromTask: child, fromParent: node)
        nodes.append(newNode)
        chartChildren(ofNode: newNode)
      }
    }
  
}
