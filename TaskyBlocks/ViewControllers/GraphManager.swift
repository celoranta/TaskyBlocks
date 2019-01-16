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
  enum Section: Int {
    case hierarchy = 0
    case dependance = 1
    case priority = 2
  }
  static let sharedInstance = GraphManager()
  private var indexRegister = 0
  private var hierarchyMaxDegree = 0
  private var incompleteRootTasks: [Tasky] { return TaskyEditor.sharedInstance.rootTasks().filter({$0.completionDate == nil})}
  var nodes: [IndexPath : TaskyNode] = [:]
  var hierarchyGraph: [TaskyNode] {
    //Returns only the root-level hierarchy nodes
    return Array(nodes.filter({$0.key[0] == Section.hierarchy.rawValue}).values.filter({$0.degree == 0}))
  }
  
  func node(for path: IndexPath) -> TaskyNode? {
    return nodes[path]
  }
  
  func siblings(of node: TaskyNode) -> [TaskyNode] {
    return Array(nodes.filter({$0.value.parent == node.parent}).values)
  }
  
  func updateGraphs() {
    clearGraphs()
    createHierarchyGraph()
    //createDependanceGraph()
    //createPriorityGraph()
  }
  
  fileprivate func createHierarchyGraph() {
    //Add root nodes to nodes array

    for i in 0..<incompleteRootTasks.count {
      let task = incompleteRootTasks[i]
      let siblingIndex = [i]
      let indexPath = IndexPath.init(item: indexRegister, section: Section.hierarchy.rawValue)
      let newNode = TaskyNode.init(fromTask: task, fromTreePath: siblingIndex)
      
      //Enter a graphing node for each index path
      nodes.updateValue(newNode, forKey: indexPath)
      indexRegister += 1

    }
    //Recurse children to create nodes for each node in forest
    //let hierarchyNodesValues = Array(nodes.filter({$0.key[0] == Section.hierarchy.rawValue}).values)
    chartDescendants(ofNodes: hierarchyGraph)
    
    guard let nodeAtMaxGen = nodes.values.max(by: {$0.degree > $1.degree})
      else {
        fatalError("Error: No node with max degree found in hierarchy tree")
    }
     hierarchyMaxDegree = nodeAtMaxGen.degree
    //Package each generation of nodes into parents' tree property
    for generation in stride(from: hierarchyMaxDegree, to: 0, by: -1) {
      for node in nodes.values.filter({$0.degree == generation}) {
        guard let parent = node.parent
          else {
            fatalError("No parent found for node")
        }
        parent.tree.append(node)
      }
    }
  }
  
  fileprivate func createDependanceGraph() {
  }
  
  fileprivate func createPriorityGraph() {
  }
  
  //Sends an array of nodes to recursive node creation function
  fileprivate func chartDescendants(ofNodes nodeArray: [TaskyNode]) {
    for node in nodeArray {
      chartChildren(ofNode: node)
    }
  }
  
  //Creates all nodes in hierarchy graph
  fileprivate func chartChildren(ofNode node: TaskyNode) {
    if node.task.children.count == 0 || node.isCollapsed == true { return }
      for child in node.task.children {
        //Find the child's location with relation to its siblings
        guard let birthOrder = node.task.children.index(of: child)
          else {
            fatalError("Error:  Task is not part of the array it was found within")
        }
        //Create the child's treepath by annexing birth order to parent's treepath
        let treePath = node.treePath + [birthOrder]
        //Create an index path using the reference to the datasource
        let indexPath = IndexPath.init(item: indexRegister, section: 0)
        
        indexRegister += 1

        let newNode = TaskyNode.init(fromTask: child, fromTreePath: treePath, fromParent: node)
//        if indexRegister == 2 { //Temporary Test
//          newNode.isCollapsed = true
//        }
        nodes.updateValue(newNode, forKey: indexPath)
        node.tree.append(newNode)
        chartChildren(ofNode: newNode)
      }
    }
  
  var hierarchyGraphMaxWidth: CGFloat { //This seems like it erroneously counts recently completed tasks' widths
    var maxWidth: CGFloat = 0.0
    for i in 0...hierarchyMaxDegree {
      let generation = nodes.filter({$0.value.degree == i}).values
      let width = generation.reduce(0, {$1.layoutAttribute.size.width + $0})
      if width > maxWidth {
        maxWidth = width
      }
    }
    return maxWidth
  }

  fileprivate func clearGraphs() {
    indexRegister = 0
    nodes = [:]
    //hierarchyGraph = []
  }
  
  override private init() {
    super.init()
    updateGraphs()
  }
}
