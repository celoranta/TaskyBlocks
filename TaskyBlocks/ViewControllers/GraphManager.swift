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
  private var nodes: [IndexPath : TaskyNode] = [:]
  private var hierarchyGraph: [TaskyNode] = []
  var treePaths: [IndexPath : TreePath] = [:]
  
  func node(for path: IndexPath) -> TaskyNode? /*Needs to return a node, not a cell*/ {
    return nodes[path]
  }
  
  func createHierarchyGraph() {
    let rootTasks = TaskyEditor.sharedInstance.TaskDatabase.filter("parents.@count = 0")
    
    //Add root nodes to nodes array
    for i in 0..<rootTasks.count {
      let task = rootTasks[i]
      let treePath = [i]
      guard let index = tasks.index(of: task)
        else {
          fatalError("Task does not exist within the array it was found within")
      }
      let indexPath = IndexPath.init(item: index, section: 0)
      treePaths.updateValue(treePath, forKey: indexPath)
      let newNode = TaskyNode.init(fromTask: task, fromTreePath: treePath, fromParent: nil)
      nodes.updateValue(newNode, forKey: indexPath)
    }
    
    //Recurse children to create nodes for each node in forest
    let nodesValues = Array(nodes.values)
    chartDescendants(ofNodes: nodesValues)
    
    //Determine total number of generations
    var maxDegree: Int
    guard let nodeAtMaxGen = nodesValues.max(by: {$0.degree > $1.degree})
      else {
        fatalError("Error: No node with max degree found in hierarchy tree")
    }
     maxDegree = nodeAtMaxGen.degree

    //Package each generation of nodes into parents' tree property
    for generation in stride(from: maxDegree, to: 0, by: -1) {
      for node in nodesValues.filter({$0.degree == generation}) {
        guard let parent = node.parent
          else {
            fatalError("No parent found for node")
        }
        parent.tree.append(node)
      }
    }
    
    //Add packaged root nodes to the overall graph 'forest'
    hierarchyGraph = []
    for node in nodesValues.filter({$0.degree == 0}) {
      hierarchyGraph.append(node)
    }
    print("Hierarchy graph: ",  hierarchyGraph)
    print("TreePaths: ", treePaths)
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
        guard let birthOrder = node.task.children.index(of: child)
          else {
            fatalError("Error:  Task is not part of the array it was found within")
        }
        let treePath = node.treePath + [birthOrder]
        guard let index = tasks.index(of: node.task)
          else {
            fatalError("Task does not exist within the array it was found within")
        }
        let indexPath = IndexPath.init(item: index, section: 0)
        treePaths.updateValue(treePath, forKey: indexPath)
        let newNode = TaskyNode.init(fromTask: child, fromTreePath: treePath, fromParent: node)
        nodes.updateValue(newNode, forKey: indexPath)
        chartChildren(ofNode: newNode)
      }
    }
  
}
