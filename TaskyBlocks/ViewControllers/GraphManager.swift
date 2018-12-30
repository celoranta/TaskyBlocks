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
  private let tasks: Results<Tasky> = TaskyEditor.sharedInstance.taskDatabase
  private var nodes: [IndexPath : TaskyNode] = [:]
  private var hierarchyGraph: [TaskyNode] = []
  var treePaths: [IndexPath : TreePath] = [:]
  
  func node(for path: IndexPath) -> TaskyNode? /*Needs to return a node, not a cell*/ {
    return nodes[path]
  }
  
  func createHierarchyGraph() {
    //let rootTasks = TaskyEditor.sharedInstance.TaskDatabase.filter("parents.@count = 0")
    
    //Add root nodes to nodes array
    for i in 0..<TaskyEditor.sharedInstance.rootTasks().count {
      let task = TaskyEditor.sharedInstance.rootTasks()[i]
      let treePath = [i]
      //Ensure that the index refers to the database and not the local copy
      //(SInce the actual objects are stored as Realm results, this
      //should probably use a realm object ID as a reference, not an index.
      guard let index = tasks.index(of: task)
        else {
          fatalError("Task does not exist within the array it was found within")
      }
      //Save the index path of the task to a variable
      let indexPath = IndexPath.init(item: index, section: 0)
      treePaths.updateValue(treePath, forKey: indexPath)
      let newNode = TaskyNode.init(fromTask: task, fromTreePath: treePath, fromParent: nil)
      //Enter a graphing node for each index path in the datasource
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
        //Find the child's location with relation to its siblings
        guard let birthOrder = node.task.children.index(of: child)
          else {
            fatalError("Error:  Task is not part of the array it was found within")
        }
        //Create the child's treepath by annexing birth order to parent's treepath
        let treePath = node.treePath + [birthOrder]
        //Create an index which references the datasource object and not the local copy
        guard let index = tasks.index(of: child)
          else {
            fatalError("Task does not exist within the array it was found within")
        }
        //Create an index path using the reference to the datasource
        let indexPath = IndexPath.init(item: index, section: 0)
        //
        treePaths.updateValue(treePath, forKey: indexPath)
        let newNode = TaskyNode.init(fromTask: child, fromTreePath: treePath, fromParent: node)
        nodes.updateValue(newNode, forKey: indexPath)
        chartChildren(ofNode: newNode)
      }
    }
  
  func node(at treePath: TreePath) -> TaskyNode? {
    var node: TaskyNode?
    for branchIndex in treePath {
      node = hierarchyGraph[branchIndex]
    }
    return node
  }
  
  func indexPath(of node: TaskyNode) -> IndexPath{
    let indexPaths = nodes.keysForValue(value: node)
    if indexPaths.count > 1 {
      fatalError("More than one index path was found for node")
    }
    return indexPaths[0]
  }
  
}
