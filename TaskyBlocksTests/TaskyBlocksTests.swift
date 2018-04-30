////
////  TaskyBlocksTests.swift
////  TaskyBlocksTests
////
////  Created by Chris Eloranta on 2018-04-04.
////  Copyright © 2018 Christopher Eloranta. All rights reserved.
////
//
//import XCTest
//import RealmSwift
//@testable import TaskyBlocks
//
//
//
//
//class BasicTaskyNodeFunctionsTest: XCTestCase {
//  
//  var manager: TaskyNodeManager!
//  
//  var node0: TaskyNode!
//  var node1: TaskyNode!
//  var node2: TaskyNode!
//  var node3: TaskyNode!
//  var node4: TaskyNode!
//  var node5: TaskyNode!
//  var node6: TaskyNode!
//  var node7: TaskyNode!
//  
//  var taskSet: Set <TaskyNode> = []
//  
//  override func setUp()
//  {
//    super.setUp()
//    manager = TaskyNodeManager()
//    
//    node0 = TaskyNode()
//    node1 = TaskyNode()
//    node2 = TaskyNode()
//    node3 = TaskyNode()
//    node4 = TaskyNode()
//    node5 = TaskyNode()
//    node6 = TaskyNode()
//    node7 = TaskyNode()
//    
//    node0.title = "Task_Root"
//    node1.title = "Task_1"
//    node2.title = "Task_2"
//    node3.title = "Task_3"
//    node4.title = "Task_4"
//    node5.title = "Task_5"
//    node6.title = "Task_6"
//    node7.title = "Task_7"
//    
//    taskSet = [node0, node1, node2, node3, node4, node5, node6, node7]
//  }
//  
//  override func tearDown()
//  {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    super.tearDown()
//    taskSet.removeAll()
//    for task in taskSet
//    {
//      task.antecedents.removeAll()
//      task.parents.removeAll()
//    }
//  }
//  
//  fileprivate func basicInheritanceHierarchy() {
//    node7.addAsChildTo(newParent: node5)
//    node6.addAsChildTo(newParent: node5)
//    node5.addAsChildTo(newParent: node4)
//    node3.addAsChildTo(newParent: node2)
//  }
//  
//  fileprivate func basicAntecedenceStructure() {
//    node7.addAsConsequentTo(newAntecedent: node4)
//    node1.addAsConsequentTo(newAntecedent: node7)
//  }
//  
//  func test_whenGivenParentWithApparentPriority_priorityIsPassedToChildren()
//  {
//    basicInheritanceHierarchy()
//    
//    basicAntecedenceStructure()
//    
//    node4.priorityOverride.value = 90
//    
//    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)
//    
//    XCTAssertEqual(node4.priorityOverride.value, node6.priorityApparent)
//    XCTAssertEqual(node6.priorityApparent, node7.priorityApparent)
//  }
//  
//  func test_whenGivenConsequentWithApparentPriority_priorityIsPassedToAntecedent() {
//    
//    basicInheritanceHierarchy()
//    
//    basicAntecedenceStructure()
//    
//    node4.priorityOverride.value = 90
//    
//    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)
//    
//    XCTAssertEqual(node7.priorityApparent, node4.priorityOverride.value)
//  }
//  
//  func test_whenUnitInheritsLowInheritedAndHighConsequence_ApparentEqualsConsequence() {
//    
//    node7.addAsChildTo(newParent: node5)
//    node5.addAsChildTo(newParent: node4)
//    node7.addAsConsequentTo(newAntecedent: node5)
//    node5.addAsConsequentTo(newAntecedent: node4)
//    
//    node4.priorityOverride.value = 80
//    node7.priorityOverride.value = 90
//    
//    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)
//    
//    //  XCTAssertEqual(node7.priorityOverride, node1.priorityApparent)
//  }
//  
//  func test_whenUnitInheritsPriorityFromTwoParents_ApparentOfChildEqualsHigherApparentOfParent() {
//    
//    node7.addAsChildTo(newParent: node0)
//    node7.addAsChildTo(newParent: node1)
//    node0.priorityOverride.value = 80
//    node1.priorityOverride.value = 90
//    
//    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)
//    
//    XCTAssertEqual(node7.priorityApparent, max(node0.priorityApparent, node1.priorityApparent))
//  }
//  func test_givenTwoConsequentsWithTwoPriorities_AntecedentInheritsHigherPriority_isTrue()
//  {
//    node7.addAsConsequentTo(newAntecedent: node5)
//    node6.addAsConsequentTo(newAntecedent: node5)
//    
//    node7.priorityOverride.value = 90
//    node6.priorityOverride.value = 20
//    
//    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)
//    
//    XCTAssertEqual(node7.priorityOverride.value, node5.priorityApparent)
//  }
//  
//  func test_WhenDirectPriorityIsSetHigherThanInherited_DirectIsResetToInherited()
//  {
//    basicInheritanceHierarchy()
//    node7.priorityDirect.value = 90
//    node5.priorityOverride.value = 20
//    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)
//    
//    XCTAssertEqual(node5.priorityOverride.value, 20)
//  }
//  func test_WhenDirectPriorityIsSetLowerThanConsequent_DirectIsResetToConsequent()
//  {
//    basicAntecedenceStructure()
//    node1.priorityOverride.value = 20
//    node7.priorityDirect.value = 90
//    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)
//    XCTAssertEqual(node7.priorityApparent, node1.priorityOverride.value)
//  }
//  func test_WhenDirectPriorityIsLessThanConsequentAndConsLessThanInher_SetToCons()
//  {
//    
//  }
//  func test_WhenDirectPriorityLessThanInherAndInherLessThanCons_SetToCons()
//  {
//    
//  }
//  
//  // If task can see its own reference via recursion, loop stops, throw error
//  // If task can see its own reference via antecedence, loop stops, throw error
//  // False cases for everhthing
//}
//
//
