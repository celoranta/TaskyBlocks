


//
//  TaskyNode.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-26.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class TaskyNode: Object

{
  
  //MAR: Ignored Properties: list of properties ignored in RealmSwift
//  override static func ignoredProperties() -> [String]
//  { return ["isPrimal", "isActionable"/*, "isPermanent"*/]
//  }

  //MARK: Properties
  
  
  @objc dynamic var title = "New Task"
  @objc dynamic var taskId = String(UUID().uuidString)
  @objc dynamic var taskDescription = ""
  @objc dynamic private (set) var taskDate = Date()
  @objc dynamic var completionDate: Date? = nil

  override static func primaryKey() -> String? {
    return "taskId"
  }

  let parents = List<TaskyNode>()
  let children = LinkingObjects(fromType: TaskyNode.self, property: "parents")
  let antecedents = List<TaskyNode>()
  let consequents = LinkingObjects(fromType: TaskyNode.self, property: "antecedents")

  @objc dynamic var priorityApparent: Double = 0
  @objc dynamic var priorityDirectDefault: Double = (50 + Double(arc4random_uniform(100)/10000))
  let priorityInherited: RealmOptional<Double> = RealmOptional.init()
  let priorityConsequent: RealmOptional<Double> = RealmOptional.init()
  let priorityDirect: RealmOptional<Double> = RealmOptional.init()  //currently no need to recalcutalate/update.  Revisit
  let priorityOverride: RealmOptional<Double> = RealmOptional.init()  //for testing by developer
  
  @objc dynamic var isPermanent: Int = -1
  //MARK: Calculated properties
  var isPrimal: Bool  //included in 'ignore' by RealmSwift
  { return parents.count == 0
  }
  @objc dynamic var isActionable: Bool  //included in 'ignore' by RealmSwift
  { return children.isEmpty
  }

  //MARK: Methods
  
  convenience init(with name: String = "New Task", and priority: Double = 50)
  {
    self.init()
    self.title = name
    print("New!")
    self.soundOff()
  }
  
  func markAsCompleted(on date: Date = Date())

  { //let realm = try! Realm()
   // realm.beginWrite()
    completionDate = Date()
    self.prepareRemove()
   // try! realm.commitWrite()
  }
  
  //MARK: TaskyNode Relational assignment
  func addAsChildTo(newParent: TaskyNode)
  { if !self.parents.contains(newParent)
  { self.parents.append(newParent)
    }
  }

  func addAsParentTo(newChild: TaskyNode)
  { if !newChild.parents.contains(self)
  { newChild.parents.append(self)
    }
  }

  func removeAsChildTo(parent: TaskyNode)
  { if let index = self.parents.index(of: parent)
  { self.parents.remove(at: index)
    }
  }

  func removeAsParentTo(child: TaskyNode)
  { if !child.parents.contains(self)
  { child.parents.append(self)
    }
  }

  func removeAsChildToAll()
  { self.parents.removeAll()
  }

  func removeAsParentToAll()
  { for child in children
  { child.removeAsChildTo(parent: self)
    }
  }

  func addAsConsequentTo(newAntecedent: TaskyNode)
  { if !self.antecedents.contains(newAntecedent)
  { self.antecedents.append(newAntecedent)
    }
  }

  func addAsAntecedentTo(newConsequent: TaskyNode)
  { newConsequent.addAsConsequentTo(newAntecedent: self)
  }

  func removeAsConsequentTo(antecedent: TaskyNode)
  { if let index = self.antecedents.index(of: antecedent)
  { self.antecedents.remove(at: index)
    }
  }

  func removeAsAntecedentTo(consequent: TaskyNode)
  { consequent.removeAsConsequentTo(antecedent: self)
  }

  func removeAsConsequentToAll()
  { self.antecedents.removeAll()
  }

  func removeAsAntecedentToAll()
  { for consequent in consequents
  { consequent.removeAsConsequentTo(antecedent: self)
    }
  }

  func prepareRemove()
  { for parent in parents
  { for child in children
  { child.addAsChildTo(newParent: parent)
    }
    }
    for antecedent in antecedents
    {for consequent in consequents
    { consequent.addAsAntecedentTo(newConsequent: antecedent)
      }
    }
  }

  // MARK: Priority Calculators:
  // Danny suggests that these functions should return a value and not mutate properties.
  // However, since the only purpose served by these methods is the calculating of
  // Apparent priority, maybe I should try again to turn them into calculated properties.
  //A task's inherited priority is the maximum of all parents' apparent priorities
  
  private func updatePriorityInherited()
  {
    self.priorityInherited.value = self.parents.max(ofProperty: "priorityApparent")
  }

  private func updatePriorityConsequent()
  {
    self.priorityConsequent.value = self.consequents.max(ofProperty: "priorityApparent")
  }

  private func updatePriorityApparent()
  {
    var priority = priorityDirect.value ?? priorityDirectDefault
    if let inherited = priorityInherited.value
    {
      priority = inherited < priority ? inherited : priority
    }
    if let consequent = priorityConsequent.value
    {
      priority = consequent > priority ? consequent : priority
    }
    self.priorityApparent = priorityOverride.value ?? priority
  }
  
  //Mark: Debugging Methods
  func soundOff()
  { print("\nHi, I'm \(self.title).")
    print("My ID is \(self.taskId)")
    print("My parents are: \(self.printMy(kin: RelationType.parents))")
    print("My children are: \(self.printMy(kin: RelationType.children))")
    print("My antecedents are: \(self.printMy(kin: RelationType.antecedents))")
    print("My consequents are: \(self.printMy(kin: RelationType.consequents))")
    if let unwrappedPriorityOverride = priorityOverride.value    {
      print("My override priority is \(unwrappedPriorityOverride)")
    }
    if let unwrappedPriorityDirect = priorityDirect.value
    { print("My direct priority is \(unwrappedPriorityDirect)")
    }
    if let unwrappedPriorityConsequent = priorityConsequent.value
    {
      print("My consequent priority is \(unwrappedPriorityConsequent)")
    }
    if let unwrappedPriorityInherited = self.priorityInherited.value
    {
      print("My inherited priority is \(unwrappedPriorityInherited)")
    }
    print("My apparent priority is \(self.priorityApparent)")
    print("Am I primal? (t/f) \(self.isPrimal).")
    print("Am I actionable? (t/f) \(self.isActionable).")
  }
  
  private func printMy(kin: RelationType) -> String
  { var returnString = ""
    switch kin
    { case RelationType.parents:
      for parent in parents
      { returnString += parent.title + " "
      }
    case RelationType.children:
      for child in children
      { returnString += child.title + " "
      }
    case RelationType.antecedents:
      for antecedent in antecedents
      {  returnString += antecedent.title + " "
      }
    case RelationType.consequents:
      for consequent in consequents
      { returnString += consequent.title + " "
      }
    }
    return returnString
  }
  
  //MARK: Class Method Definitions: TO BE MOVED TO MANAGER
  
  //Danny note:/master update instance method to call each priority update individually and return an update record
  func updateMyPriorities() -> (TaskRecord)  //Returns a tasks UUID and priorityApparent
  { updatePriorityInherited()
    //   DannyNote: let newPritoryApprent = updatePriorityInherited()
    updatePriorityConsequent()
    updatePriorityApparent()
    return (self.taskId, self.priorityApparent)
  }
  
  class func updatePriorityFor(tasks: Set<TaskyNode>,limit:Int)
  { var currentTaskRecords: [String:Double] = [:]
    var previousTaskRecords = ["dummy": 99.9] //ensures the first pass has a non-nil unequal dict to compare against, as to to ensure we enter a second pass.
    let anyNonZeroInt = 42 // Remove this and use "while repeat" below?
    var recordsChanged = anyNonZeroInt //ensures that we enter the loop with a non-nil, non-zero value
    var updatesPerformed: [String:Int] = [:]
    while recordsChanged != 0
    { for task in tasks
    { let taskRecord: TaskRecord = task.updateMyPriorities()
      currentTaskRecords.updateValue(taskRecord.priority, forKey: taskRecord.taskId)
      if let oldCount = updatesPerformed.removeValue(forKey: taskRecord.taskId)
      { let newCount = oldCount + 1
        updatesPerformed.updateValue(newCount, forKey: taskRecord.taskId)
      }
      else
      { updatesPerformed.updateValue(1, forKey:taskRecord.taskId)
      }
      // guard //counter is over limit & return updates performed
      task.soundOff()
      }
      print(updatesPerformed) //this is calculating incorrectly, but error doesn't affect logic
      recordsChanged = countNonMatchingKeyValuePairsBetween(dict1: currentTaskRecords, dict2: previousTaskRecords)
      print(recordsChanged)
      previousTaskRecords = currentTaskRecords
      currentTaskRecords = [:]
    }
    return
  }
//  
//  required convenience init(forUse: Bool = true)
//  {
//    //let filter = "completionDate == nil"
//    
//     let realm = try! Realm()
//   // realm.beginWrite()
//    
//    self.init()
//    self.priorityDirectDefault = 50.00 + (Double(arc4random_uniform(1000))/1000)
//    realm.add(self)
//    
//    //TaskyNode.updatePriorityFor(tasks: Set(realm.objects(TaskyNode.self).filter(filter)), limit: 100)
//   // realm.refresh()
//    //try! realm.commitWrite()
//  }
//  
  class func countNonMatchingKeyValuePairsBetween(dict1: [String:Double], dict2: [String:Double]) -> Int
  {
    var count = 0
    var dict2Mutable = dict2
    for entry in dict1
    { if let valueForMatchedKey = dict2Mutable.removeValue(forKey: entry.key)
    { if entry.value != valueForMatchedKey {count += 1}
    }
    else {count += 1}
    }
    return count
  }
}

extension TaskyNode {
  
  var uniqueKey: String {
    get {
      return "\(priorityApparent)\(taskId)"
    }
}
}

