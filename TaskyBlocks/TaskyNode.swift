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

  
  var title = "New Task"
  internal fileprivate(set) var taskId: String
  var taskDescription = ""
  let taskDate = Date()
  
  internal fileprivate(set) var parents: [TaskyNode] = []
  internal fileprivate(set) var children: [TaskyNode] = []
  internal fileprivate(set) var antecedents: [TaskyNode] = []
  internal fileprivate(set) var consequents: [TaskyNode] = []
  fileprivate var completionDate: Date? = nil
  var isComplete: Bool
  {
    if completionDate == nil
    {
      return false
    }
    else
    {
      return true
    }
  }

  internal fileprivate(set) var priorityApparent: Double = 0
  var priorityInherited: Double = 0
  var priorityConsequent: Double = 0
  var priorityDirect: Double? //currently no need to recalcutalate/update.  Revisit
  var priorityOverride: Double? //for testing by developer
  var priorityDirectDefault: Double
  
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
    let anyNonZeroInt = 42 // Remove this and use "while repeat" below?
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
  
  func removeAsChildTo(parent: TaskyNode)
  {
    if let parentIndex = self.parents.index(of: parent)
    {
      self.parents.remove(at: parentIndex)
    }
    if let childIndex = parent.children.index(of: self)
    {
      parent.children.remove(at: childIndex)
    }
  }
  
  func removeAsChildToAll()
  {
    for parent in self.parents
    {
      self.removeAsChildTo(parent: parent)
    }
  }
  
  func addAsParentTo(newChild: TaskyNode)
  {
    if !self.children.contains(newChild)
    {
      self.children.append(newChild)
    }
    for child in children
    {
      if !child.parents.contains(self)
      {
        child.parents.append(self)
      }
    }
  }
  
  func removeAsParentTo(child: TaskyNode)
  {
    if let childIndex = self.children.index(of: child)
    {
      self.children.remove(at: childIndex)
    }
    if let parentIndex = child.parents.index(of: self)
    {
      child.parents.remove(at: parentIndex)
    }
  }
  
  func removeAsParentToAll()
  {
    for child in self.children
    {
      self.removeAsParentTo(child: child)
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
  
  func prepareRemove()
  {
    for child in children
    {
      for parent in parents
      {
        if !parent.children.contains(child)
        {
          parent.children.append(child)
        }
        if !child.parents.contains(parent)
        {
          child.parents.append(parent)
        }
      }
    }
  }

  func markAsCompleted(on: Date = Date())
  {
    completionDate = Date()
  }

  
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
  
  //A tasks's consequent priority is the maximum of all consequents' apparent priorities
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
    
    let maxInheritanceTask = parents.max { $0.priorityApparent < $1.priorityApparent }
    let inheritance = maxInheritanceTask?.priorityApparent ?? 100.00
    let maxDependenceTask = consequents.max { $0.priorityApparent < $1.priorityApparent }
    let dependence = maxDependenceTask?.priorityApparent ?? 0.00
    let direct = priorityDirect ?? priorityDirectDefault
    let priorities = (dependence: dependence,inheritance: inheritance,direct: direct)
    var priorityRegister: Double
    if priorityOverride != nil
    {
      priorityRegister = priorityOverride!
    }
    else if priorities.dependence >= priorities.direct
    {
      priorityRegister = priorities.dependence
    }
    else if priorities.inheritance <= priorities.direct
    {
      priorityRegister = priorities.inheritance
    }
    else
    {
    priorityRegister = priorities.direct
    }
    //if priorityOverride != nil, return priorityOverride
    //if consequent >= calcDirect, use consequent
    //if inherited <= calcDirect, use inherited
    //if priorityDirect = nil, use defaultPriorityDirect
    //else use priorityDirect
    
    //let inherited = self.parents.max { $0.priorityApparent < $1.priorityApparent }
    //let inherited = self.parents.priorityApparent.max()
    
//    var priorityRegister: Double!
//    priorityRegister = self.priorityInherited
//    let postDefaultPriorityDirect = priorityDirect ?? priorityDirectDefault
//    if priorityRegister > postDefaultPriorityDirect
//    {
//      priorityRegister = postDefaultPriorityDirect
//    }
//    if priorityRegister < self.priorityConsequent
//    {
//      priorityRegister = self.priorityConsequent
//    }
//    if let priorityOverrideUnwrapped = self.priorityOverride
//    {
//      priorityRegister = priorityOverrideUnwrapped
//    }
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
    self.priorityDirectDefault = 50.00
    self.taskId = String(UUID().uuidString)
    super.init()
  }
  
  deinit
  {
    prepareRemove()
  }
}

extension TaskyNode {
  
  var uniqueKey: String {
    get {
      return "\(priorityApparent)\(taskId)"
    }
  }
  
  
}

//
////
////  TaskyNode.swift
////  TestOrdinatorGraphics
////
////  Created by Chris Eloranta on 2018-03-26.
////  Copyright © 2018 Christopher Eloranta. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//
//class TaskyNode: Object
//
//{
//  //list of properties ignored in RealmSwift
//  override static func ignoredProperties() -> [String]
//  { return ["isComplete", "isPrimal", "isActionable"]
//  }
//
//  //MARK: Properties
//  @objc dynamic var title = "New Task"
//  @objc dynamic var taskId = String(UUID().uuidString)
//  @objc dynamic var taskDescription = ""
//  @objc dynamic var taskDate = Date()
//  @objc dynamic var completionDate: Date? = nil
//
//  let parents = List<TaskyNode>()
//  let children = LinkingObjects(fromType: TaskyNode.self, property: "parents")
//  let antecedents = List<TaskyNode>()
//  let consequents = LinkingObjects(fromType: TaskyNode.self, property: "antecedents")
//
//  @objc dynamic var priorityApparent: Double = 0
//  @objc dynamic var priorityInherited: Double = 0
//  @objc dynamic var priorityConsequent: Double = 0
//  @objc dynamic var priorityDirectDefault: Double = 50
//  let priorityDirect: RealmOptional = RealmOptional.init(0.00) //currently no need to recalcutalate/update.  Revisit
//  let priorityOverride: RealmOptional = RealmOptional.init(0.00) //for testing by developer
//
//  //MARK: Calculated properties
//  var isPrimal: Bool  //included in 'ignore' by RealmSwift
//  { return parents.count == 0
//  }
//
//  var isActionable: Bool  //included in 'ignore' by RealmSwift
//  { return children.isEmpty
//  }
//  var isComplete: Bool  //included in 'ignore' by RealmSwift
//  { if completionDate == nil
//  { return false
//  }
//  else
//  { return true
//    }
//  }
//
//  //MARK: Class Method Definition: TO BE MOVED TO MANAGER
//  class func updatePriorityFor(tasks: Set<TaskyNode>,limit:Int)
//  { var currentTaskRecords: [String:Double] = [:]
//    var previousTaskRecords = ["dummy": 99.9] //ensures the first pass has a non-nil unequal dict to compare against, as to to ensure we enter a second pass.
//    let anyNonZeroInt = 42 // Remove this and use "while repeat" below?
//    var recordsChanged = anyNonZeroInt //ensures that we enter the loop with a non-nil, non-zero value
//    var updatesPerformed: [String:Int] = [:]
//    while recordsChanged != 0
//    { for task in tasks
//    { let taskRecord: TaskRecord = task.updateMyPriorities()
//      currentTaskRecords.updateValue(taskRecord.priority, forKey: taskRecord.taskId)
//      if let oldCount = updatesPerformed.removeValue(forKey: taskRecord.taskId)
//      { let newCount = oldCount + 1
//        updatesPerformed.updateValue(newCount, forKey: taskRecord.taskId)
//      }
//      else
//      { updatesPerformed.updateValue(1, forKey:taskRecord.taskId)
//      }
//      // guard //counter is over limit & return updates performed
//      task.soundOff()
//      }
//      print(updatesPerformed) //this is calculating incorrectly, but error doesn't affect logic
//      recordsChanged = countNonMatchingKeyValuePairsBetween(dict1: currentTaskRecords, dict2: previousTaskRecords)
//      print(recordsChanged)
//      previousTaskRecords = currentTaskRecords
//      currentTaskRecords = [:]
//    }
//    return
//  }
//
//  //Mark: Debugging Methods
//  func soundOff()
//  { print("\nHi, I'm \(self.title).")
//    print("My ID is \(self.taskId)")
//    print("My parents are: \(self.printMy(kin: RelationType.parents))")
//    print("My children are: \(self.printMy(kin: RelationType.children))")
//    print("My antecedents are: \(self.printMy(kin: RelationType.antecedents))")
//    print("My consequents are: \(self.printMy(kin: RelationType.consequents))")
//    if let unwrappedPriorityOverride = priorityOverride.value    {
//      print("My override priority is \(unwrappedPriorityOverride)")
//    }
//    if let unwrappedPriorityDirect = priorityDirect.value
//    { print("My direct priority is \(unwrappedPriorityDirect)")
//    }
//    print("My consequent priority is \(self.priorityConsequent)")
//    print("My inherited priority is \(self.priorityInherited)")
//    print("My apparent priority is \(self.priorityApparent)")
//    print("Am I primal? (t/f) \(self.isPrimal).")
//    print("Am I actionable? (t/f) \(self.isActionable).")
//  }
//
//  private func printMy(kin: RelationType) -> String
//  { var returnString = ""
//    switch kin
//    { case RelationType.parents:
//      for parent in parents
//      { returnString += parent.title + " "
//      }
//    case RelationType.children:
//      for child in children
//      { returnString += child.title + " "
//      }
//    case RelationType.antecedents:
//      for antecedent in antecedents
//      {  returnString += antecedent.title + " "
//      }
//    case RelationType.consequents:
//      for consequent in consequents
//      { returnString += consequent.title + " "
//      }
//    }
//    return returnString
//  }
//
//  //MARK: TaskyNode Relational assignment methods
//  func addAsChildTo(newParent: TaskyNode)
//  { if !self.parents.contains(newParent)
//  { self.parents.append(newParent)
//    }
//  }
//
//  func addAsParentTo(newChild: TaskyNode)
//  { if !newChild.parents.contains(self)
//  { newChild.parents.append(self)
//    }
//  }
//
//  func removeAsChildTo(parent: TaskyNode)
//  { if let index = self.parents.index(of: parent)
//  { self.parents.remove(at: index)
//    }
//  }
//
//  func removeAsParentTo(child: TaskyNode)
//  { if !child.parents.contains(self)
//  { child.parents.append(self)
//    }
//  }
//
//  func removeAsChildToAll()
//  { self.parents.removeAll()
//  }
//
//  func removeAsParentToAll()
//  { for child in children
//  { child.removeAsChildTo(parent: self)
//    }
//  }
//
//  func addAsConsequentTo(newAntecedent: TaskyNode)
//  { if !self.antecedents.contains(newAntecedent)
//  { self.antecedents.append(newAntecedent)
//    }
//  }
//
//  func addAsAntecedentTo(newConsequent: TaskyNode)
//  { newConsequent.addAsConsequentTo(newAntecedent: self)
//  }
//
//  func removeAsConsequentTo(antecedent: TaskyNode)
//  { if let index = self.antecedents.index(of: antecedent)
//  { self.antecedents.remove(at: index)
//    }
//  }
//
//  func removeAsAntecedentTo(consequent: TaskyNode)
//  { consequent.removeAsConsequentTo(antecedent: self)
//  }
//
//  func removeAsConsequentToAll()
//  { self.antecedents.removeAll()
//  }
//
//  func removeAsAntecedentToAll()
//  { for consequent in consequents
//  { consequent.removeAsConsequentTo(antecedent: self)
//    }
//  }
//
//  func prepareRemove()
//  { for parent in parents
//  { for child in children
//  { child.addAsChildTo(newParent: parent)
//    }
//    }
//    for antecedent in antecedents
//    {for consequent in consequents
//    { consequent.addAsAntecedentTo(newConsequent: antecedent)
//      }
//    }
//  }
//
//  func markAsCompleted(on: Date = Date())
//  { completionDate = Date()
//  }
//
//  //Danny note:/master update instance method to call each priority update individually and return an update record
//  func updateMyPriorities() -> (TaskRecord)  //Returns a tasks UUID and priorityApparent
//  { updatePriorityInherited()
//    //   DannyNote: let newPritoryApprent = updatePriorityInherited()
//    updatePriorityConsequent()
//    updatePriorityApparent()
//    return (self.taskId, self.priorityApparent)
//  }
//
//  //A task's inherited priority is the maximum of all parents' apparent priorities
//  private func updatePriorityInherited()
//  { var priorityRegister: Double = 0.00
//    for parent in parents
//    {
//      if parent.priorityApparent > priorityRegister
//      { priorityRegister = parent.priorityApparent
//      }
//    }
//    self.priorityInherited = priorityRegister
//  }
//
//  // Danny note: //A task's inherited priority is the maximum of all parents' apparent priorities
//  //  private func updatePriorityInherited() -> Double
//  //  {
//  //    var priorityRegister: Double = 0.00
//  //    for parent in parents{
//  //      if parent.priorityApparent > priorityRegister
//  //      {
//  //        priorityRegister = parent.priorityApparent
//  //      }
//  //    }
//  //    return priorityRegister
//  //  }
//  //
//
//  //A tasks's consequent priority is the maximum of all consequents' apparent priorities
//  private func updatePriorityConsequent()
//  { var priorityRegister: Double = 0.0
//    for consequent in consequents
//    { if consequent.priorityApparent > priorityRegister
//    { priorityRegister = consequent.priorityApparent
//      }
//    }
//    self.priorityConsequent = priorityRegister
//  }
//
//  private func updatePriorityApparent()
//  { let maxInheritanceTask = parents.max { $0.priorityApparent < $1.priorityApparent
//    }
//    let maxDependenceTask = consequents.max { $0.priorityApparent < $1.priorityApparent
//    }
//    let inheritance = maxInheritanceTask?.priorityApparent ?? 100.00
//    let dependence = maxDependenceTask?.priorityApparent ?? 0.00
//    let direct = priorityDirect.value ?? priorityDirectDefault
//    let priorities = (dependence: dependence,inheritance: inheritance,direct: direct)
//    var priorityRegister: Double
//    if priorityOverride.value != nil
//    { priorityRegister = priorityOverride.value!
//    }
//    else if priorities.dependence >= priorities.direct
//    { priorityRegister = priorities.dependence
//    }
//    else if priorities.inheritance <= priorities.direct
//    { priorityRegister = priorities.inheritance
//    }
//    else
//    { priorityRegister = priorities.direct
//    }
//    self.priorityApparent = priorityRegister
//  }
//
//  class func countNonMatchingKeyValuePairsBetween(dict1: [String:Double], dict2: [String:Double]) -> Int
//  {
//    var count = 0
//    var dict2Mutable = dict2
//    for entry in dict1
//    { if let valueForMatchedKey = dict2Mutable.removeValue(forKey: entry.key)
//    { if entry.value != valueForMatchedKey {count += 1}
//    }
//    else {count += 1}
//    }
//    return count
//  }
//
//  deinit
//  { prepareRemove()
//  }
//  //
//} //MARK: End of Class Definition
//
//extension TaskyNode
//{ var uniqueKey: String
//  { get
//  { return "\(priorityApparent)\(taskId)"
//  }
//  }
//}

