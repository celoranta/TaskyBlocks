//
//  TaskyNode.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-26.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class TaskyNode: NSObject
{
  typealias TaskRecord = (taskId: String, priority: Double)
  
  var title = "New Task"
  var taskId: String
  var taskDescription: String!
  let taskDate = Date()
  
  var parents: [TaskyNode] = []
  var children: [TaskyNode] = []
  var antecedents: [TaskyNode] = []
  var consequents: [TaskyNode] = []

  var priorityApparent: Double = 0
  var priorityInherited: Double = 0
  var priorityConsequent: Double = 0
  var priorityDirect: Double? //currently no need to recalcutalate/update.  Revisit
  var priorityOverride: Double? //for testing by developer
  var priorityDefaulted: Bool = true
  
  var isPrimal: Bool
  {
    return parents.isEmpty
  }
  
  var isActionable: Bool
  {
    return children.isEmpty
  }
  
  class func updatePriorityFor(tasks: Set<TaskyNode>,limit:Int)
  {
    var currentTaskRecords: [String:Double] = [:]
    var previousTaskRecords = ["dummy": 99.9] //ensures the first pass has a non-nil unequal dict to compare against, as to to ensure we enter a second pass.
    let anyNonZeroInt = 42
    var recordsChanged = anyNonZeroInt //ensures that we enter the loop with a non-nil, non-zero value
    var updatesPerformed: [String:Int] = [:]
    while recordsChanged != 0
    {
      for task in tasks
      {
        let taskRecord: TaskRecord = task.updateMyPriorities()
        currentTaskRecords.updateValue(taskRecord.priority, forKey: taskRecord.taskId)
        if let oldCount = updatesPerformed.removeValue(forKey: taskRecord.taskId)
        {
          let newCount = oldCount + 1
          updatesPerformed.updateValue(newCount, forKey: taskRecord.taskId)
        }
        else
        {
          updatesPerformed.updateValue(1, forKey:taskRecord.taskId)
        }
        
        // guard //counter is over limit & return updates performed
        task.soundOff()
      }
      print(updatesPerformed) //this is calculating incorrectly, error doesn't affect logic
      recordsChanged = countNonMatchingKeyValuePairsBetween(dict1: currentTaskRecords, dict2: previousTaskRecords)
      print(recordsChanged)
      previousTaskRecords = currentTaskRecords
      currentTaskRecords = [:]
    }
    return
  }
  enum RelationType
  {
    case parents, children, antecedents, consequents
  }
  
  //Mark: Debugging Methods
  func soundOff()
  {
    print("\nHi, I'm \(self.title).")
    print("My ID is \(self.taskId)")
    print("My parents are: \(self.printMy(kin: RelationType.parents))")
    print("My children are: \(self.printMy(kin: RelationType.children))")
    print("My antecedents are: \(self.printMy(kin: RelationType.antecedents))")
    print("My consequents are: \(self.printMy(kin: RelationType.consequents))")
    if let unwrappedPriorityOverride = priorityOverride
    {
      print("My override priority is \(unwrappedPriorityOverride)")
    }
    if let unwrappedPriorityDirect = priorityDirect
    {
    print("My direct priority is \(unwrappedPriorityDirect)")
    }
    print("My consequent priority is \(self.priorityConsequent)")
    print("My inherited priority is \(self.priorityInherited)")
    print("My apparent priority is \(self.priorityApparent)")
    print("Am I primal? (t/f) \(self.isPrimal).")
    print("Am I actionable? (t/f) \(self.isActionable).")
  }
  
  private func printMy(kin: RelationType)->String
  {
    var returnString = ""
    switch kin
    {
    case RelationType.parents:
      for parent in parents
      {
        returnString += parent.title + " "
      }
    case RelationType.children:
      for child in children
      {
        returnString += child.title + " "
      }
    case RelationType.antecedents:
      for antecedent in antecedents
      {
        returnString += antecedent.title + " "
      }
    case RelationType.consequents:
      for consequent in consequents
      {
        returnString += consequent.title + " "
      }
    }
    return returnString
  }
  
  //Mark: TaskyNode Relational methods
  func addAsChildTo(newParent: TaskyNode)
  {
    if !self.parents.contains(newParent)
    {
      self.parents.append(newParent)
    }
    for parent in parents
    {
      if !parent.children.contains(self)
      {
        parent.children.append(self)
      }
    }
  }
  func addAsConsequentTo(newAntecedent: TaskyNode)
  {
    if !self.antecedents.contains(newAntecedent)
    {
      self.antecedents.append(newAntecedent)
    }
    for antecedent in antecedents
    {
      if !antecedent.consequents.contains(self)
      {
        antecedent.consequents.append(self)
      }
    }
  }
  
  //  func deleteDiscrete()
  //  {
  //    for child in children
  //    {
  //      for parent in parents
  //      {
  //        if !parent.children.contains(child)
  //        {
  //          parent.children.append(child)
  //        }
  //        if !child.parents.contains(parent)
  //        {
  //          child.parents.append(parent)
  //        }
  //      }
  //    }
  //    // call delegate to delete me?
  //  }
  
  //Danny note:/master update instance method to call each priority update individually and return an update record
  func updateMyPriorities() -> (TaskRecord)  //Returns a tasks UUID and priorityApparent
  {
    updatePriorityInherited()
    //   DannyNote: let newPritoryApprent = updatePriorityInherited()
    updatePriorityConsequent()
    updatePriorityApparent()
    return (self.taskId, self.priorityApparent)
  }
  
  //A task's inherited priority is the maximum of all parents' apparent priorities
  private func updatePriorityInherited()
  {
    var priorityRegister: Double = 0.00
    for parent in parents{
      if parent.priorityApparent > priorityRegister
      {
        priorityRegister = parent.priorityApparent
      }
    }
    self.priorityInherited = priorityRegister
  }
  
  // Danny note: //A task's inherited priority is the maximum of all parents' apparent priorities
//  private func updatePriorityInherited() -> Double
//  {
//    var priorityRegister: Double = 0.00
//    for parent in parents{
//      if parent.priorityApparent > priorityRegister
//      {
//        priorityRegister = parent.priorityApparent
//      }
//    }
//    return priorityRegister
//  }
//
  
  //A tasks's consequent priority is the maximum of all antecedents' apparent priorities
  private func updatePriorityConsequent()
  {
    var priorityRegister: Double = 0.0
    for consequent in consequents
    {
      if consequent.priorityApparent > priorityRegister
      {
        priorityRegister = consequent.priorityApparent
      }
    }
    self.priorityConsequent = priorityRegister
  }
  
  //A task's apparent priority is calculated from all other priority levels
  private func updatePriorityApparent()
  {
    // Danny note: if & else if vs a bunch of ifs. This would reqwuire you to reverse the order.
    var priorityRegister: Double!
    priorityRegister = self.priorityInherited
    if let unwrappedPriorityDirect = priorityDirect
    {
    if priorityRegister > unwrappedPriorityDirect {priorityRegister = unwrappedPriorityDirect}
    }
    if priorityRegister < self.priorityConsequent {priorityRegister = self.priorityConsequent}
    if let priorityOverrideUnwrapped = self.priorityOverride{priorityRegister = priorityOverrideUnwrapped
      
    }
    self.priorityApparent = priorityRegister
  }
  
  class func countNonMatchingKeyValuePairsBetween(dict1: [String:Double], dict2: [String:Double]) -> Int
  {
    var count = 0
    var dict2Mutable = dict2
    for entry in dict1
    {// if the key exists in the other dictionary...
      if let valueForMatchedKey = dict2Mutable.removeValue(forKey: entry.key)
      {// and the value has changed since the previous pass, increment the count
        if entry.value != valueForMatchedKey {count += 1}
      }// if the key does not exist in the other dictionary... increment the count
      else {count += 1}
      // by process of elimination, the count has been incremented for each key/value pair which did NOT have an identical key/value pair in the other dictionary.
    }
    return count
  }
  
  override init()
  {
    self.taskId = String(UUID().uuidString)
    super.init()
  }
}

extension TaskyNode {
  
  var uniqueKey: String {
    get {
      return "\(priorityApparent)\(taskId)"
    }
  }
}
