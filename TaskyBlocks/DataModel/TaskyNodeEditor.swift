//
//  TaskyNodeEditor.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-14.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

enum NewTaskyType
{
case normal, random
}

class TaskyNodeEditor: NSObject {

  private let realm: Realm
  let database: Results<TaskyNode>
  static let sharedInstance = TaskyNodeEditor()
    var notificationToken: NotificationToken? = nil

  //MARK: Task Creation
  func newTask() -> TaskyNode
  {
    var newTaskyNode: TaskyNode!
    let userSettings = UserDefaults()
    var taskType: NewTaskyType
    switch userSettings.bool(forKey: "NewTasksAreRandom")
    {
    case true:
      taskType = NewTaskyType.random
      
    case false:
      taskType = NewTaskyType.normal
    }
    switch taskType
    {
    case .normal:
      try! realm.write {
      newTaskyNode = TaskyNode()
      realm.add(newTaskyNode, update: true)
      }
    case .random:
      let newTaskyNodeArray = createRandomTasks(qty: 1)
      newTaskyNode = newTaskyNodeArray[0]
    }
    TaskyNodeEditor.sharedInstance.updateAllActivePriorities()
    guard let returnTask = realm.object(ofType: TaskyNode.self, forPrimaryKey: newTaskyNode.taskId)
    else
    {
      fatalError("Realm returned a non-Task object")
    }
    return returnTask
  }

  //MARK: Task Editing
  func makePermanent(task: TaskyNode)
  {
    realm.beginWrite()
    task.isPermanent = 1
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func changeTitle(task: TaskyNode, to title: String)
  {
    realm.beginWrite()
    task.title = title
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func setDirectPriority(of task: TaskyNode, to priority: Double)
  {
    realm.beginWrite()
    task.priorityDirect.value = priority
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func complete(task: TaskyNode)
  {
    if task.isPermanent != 1
    {
    realm.beginWrite()
    task.completionDate = Date()
    realm.add(task, update: true)
    try! realm.commitWrite()
    print("Tasky node \(task.title) with id: \(task.taskId) was marked complete")
    }
    else
    {
      print("Tasky node \(task.title) with id: \(task.taskId) is permanent and cannot be marked complete")
    }
  }
  
  //MARK: Task Removal prep
  
  func prepareRemove(task: TaskyNode)
  {
    for parent in task.parents
  { for child in task.children
  { add(task: child, AsChildTo: parent)
    }
    }
    for antecedent in task.antecedents
    {for consequent in task.consequents
    { add(task: consequent, asConsequentTo: antecedent)
      }
    }
  }
  
  //MARK: Task Description
  func updateTaskDescription(for task: TaskyNode, with text: String)
  {
    realm.beginWrite()
    task.taskDescription = text
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  //MARK: TaskyNode Relational Assignment Edits
  
  func add(task: TaskyNode, AsChildTo newParent: TaskyNode)
  { realm.beginWrite()
    if !task.parents.contains(newParent)
  { task.parents.append(newParent)
    realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func add(task: TaskyNode, asParentTo newChild: TaskyNode)
  {
    realm.beginWrite()
    if !newChild.parents.contains(task)
  { newChild.parents.append(task)
    realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func remove(task: TaskyNode, asChildTo parent: TaskyNode)
  { realm.beginWrite()
    if let index = task.parents.index(of: parent)
  { task.parents.remove(at: index)
    realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func remove(task: TaskyNode, asParentTo child: TaskyNode)
  { realm.beginWrite()
    if !child.parents.contains(task)
  { child.parents.append(task)
    realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func removeAsChildToAllParents(task: TaskyNode)
  { realm.beginWrite()
    task.parents.removeAll()
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func removeAsParentToAllChildren(task: TaskyNode)
  {
    for child in task.children
  { remove(task: child, asChildTo: task)
    }
  }
  
  func add(task: TaskyNode, asConsequentTo newAntecedent: TaskyNode)
  { realm.beginWrite()
    if !task.antecedents.contains(newAntecedent)
  { task.antecedents.append(newAntecedent)
    realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func add(task: TaskyNode, asAntecedentTo newConsequent: TaskyNode)
  {
    TaskyNodeEditor.sharedInstance.add(task: newConsequent, asConsequentTo: task)
  }
  
  func remove(task: TaskyNode, asConsequentTo antecedent: TaskyNode)
  { realm.beginWrite()
    if let index = task.antecedents.index(of: antecedent)
  { task.antecedents.remove(at: index)
    realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func remove(task: TaskyNode, asAntecedentTo consequent: TaskyNode)
  {
    TaskyNodeEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
  }
  
  func removeAsConsequentToAll(task: TaskyNode)
  { realm.beginWrite()
    task.antecedents.removeAll()
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func removeAsAntecedentToAll(task: TaskyNode)
  { for consequent in task.consequents
  {
    TaskyNodeEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
    }
  }

  //MARK: Write session management
//  private func saveChanges()
//  {
//   // try! realm.commitWrite()
//    print("Write session committed")
//   // realm.beginWrite()
//    print("New write session opened")
//    // call update priorities here
//  }
  
//  private func abandonChanges()
//  {
//    realm.cancelWrite()
//    print("Write session abandoned")
//    realm.beginWrite()
//    print("New write session opened")
//  }

  //MARK: Initializers
  override private init()
  {
    var i = 0
    var newRealmInstanceAttempt: Realm? = nil
    var realmInstance: Realm!
    print("\n")
    while realmInstance == nil
    {
      i += 1
      print("Connecting to realm...  Attempt #\(i)")
      newRealmInstanceAttempt = try! Realm()
      if let uNewRealmDistance = newRealmInstanceAttempt
      {
        realmInstance = uNewRealmDistance
      }
      guard i < 10
        else
      {
        fatalError("Fatal Error:  Could not connect to realm")
      }
    }
    self.realm = realmInstance
    print("Realm instance created")
    self.database = realm.objects(TaskyNode.self)
    print("Database created in memory")
    super.init()
    print("New write session begun")
  }

  deinit
  {
    print("editor deinitialization:")
    print("Saved changes and closed write session")
    print("Realm instance closed")
  }
  
  /////


  func updatePriorityDirect(of task: TaskyNode, to value: Double)
{
  try! realm.write {
    task.priorityDirect.value = value
  }
  }

// MARK: Priority Calculators:
// Danny suggests that these functions should return a value and not mutate properties.
// However, since the only purpose served by these methods is the calculating of
// Apparent priority, maybe I should try again to turn them into calculated properties.
//A task's inherited priority is the maximum of all parents' apparent priorities

private func updatePriorityInherited(of task: TaskyNode)
{
  try! realm.write{
  task.priorityInherited.value = task.parents.max(ofProperty: "priorityApparent")
}
}

private func updatePriorityConsequent(of task: TaskyNode)
{
  try! realm.write {
  task.priorityConsequent.value = task.consequents.max(ofProperty: "priorityApparent")
}
  }

private func updatePriorityApparent(of task: TaskyNode)
{
  var priority = task.priorityDirect.value ?? task.priorityDirectDefault
  if let inherited = task.priorityInherited.value
  {
    priority = inherited < priority ? inherited : priority
  }
  if let consequent = task.priorityConsequent.value
  {
    priority = consequent > priority ? consequent : priority
  }
  try! realm.write {
  task.priorityApparent = task.priorityOverride.value ?? priority
}
  }


//MARK: Class Method Definitions: TO BE MOVED TO MANAGER

//Danny note:/master update instance method to call each priority update individually and return an update record
  func updatePriorities(of task: TaskyNode) -> (TaskRecord)  //Returns a tasks UUID and priorityApparent
  { updatePriorityInherited(of: task)
  //   DannyNote: let newPritoryApprent = updatePriorityInherited()
    updatePriorityConsequent(of: task)
    updatePriorityApparent(of: task)
  return (task.taskId, task.priorityApparent)
}

func updatePriorityFor(tasks: Set<TaskyNode>,limit:Int)
{ var currentTaskRecords: [String:Double] = [:]
  var previousTaskRecords = ["dummy": 99.9] //ensures the first pass has a non-nil unequal dict to compare against, as to to ensure we enter a second pass.
  let anyNonZeroInt = 42 // Remove this and use "while repeat" below?
  var recordsChanged = anyNonZeroInt //ensures that we enter the loop with a non-nil, non-zero value
  var updatesPerformed: [String:Int] = [:]
  while recordsChanged != 0
  { for task in tasks
  { let taskRecord: TaskRecord = updatePriorities(of: task)
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
  
  func countNonMatchingKeyValuePairsBetween(dict1: [String:Double], dict2: [String:Double]) -> Int
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

  /////
  
  
  func updateAllActivePriorities()
  {
    updatePriorityFor(tasks: Set(self.database.filter("completionDate == nil")), limit: 100)
  }
  
  func createRandomTasks(qty: Int = 1) -> [TaskyNode]
  {
    realm.beginWrite()
    var randomTaskSet: [TaskyNode] = []
    for _ in 0..<qty
    {
      let newTasky = TaskyNode()
      randomTaskSet.append(newTasky)
    }

    
    var verbs = ["Eat", "Wash", "Plead With", "Feed", "Buy", "Exercise", "Fluff", "Make", "Cook", "Ponder", "Enable", "Dominate", "Contemplate", "Avoid", "Eliminate", "Flog", "Threaten", "Pacify", "Enrage", "Bewilder", "Frighten", "Placate", "Interrogate", "Moisten", "Shuck", "Wax", "Surveil", "Alarm", "Annoy", "Frustrate", "Telephone", "Buffalo", "Berate", "Seduce", "Scrub"]
    var nouns = ["Dog", "Dishes", "Car", "Neighbors", "Laundry", "Bathroom", "Bills", "Kids", "Boss", "Pool", "Yard", "Garage", "Garden", "Fridge", "Inlaws", "Cat", "Baby", "Shed", "TV", "Light Fixtures", "Neighborhood", "Rent", "China", "Taxes", "Deacon", "Postman", "Telephone", "Buffalo", "Local Urchins", "Garbage"]

    for task in randomTaskSet
    {
      let verbQty = UInt32(verbs.count)
      let nounQty = UInt32(nouns.count)
      let rand1 = Int(arc4random_uniform(verbQty - 1))
      let rand2 = Int(arc4random_uniform(nounQty - 1))
      let nameString = "\(verbs.remove(at: Int(rand1))) the \(nouns.remove(at: rand2))"
      let randomPriority = Double(arc4random_uniform(99) + 1)
      try! realm.write {
        realm.add(task, update: true)
      }

      TaskyNodeEditor.sharedInstance.setDirectPriority(of: task, to: randomPriority)
      TaskyNodeEditor.sharedInstance.changeTitle(task: task, to: nameString)
      let taskDescription =
      """
      Spicy jalapeno bacon ipsum dolor amet consequat ipsum fugiat jowl ut elit occaecat strip steak. Reprehenderit chuck tempor laborum bresaola dolore irure. Brisket tenderloin esse kielbasa culpa mollit ut. Consectetur in ham pork loin, hamburger burgdoggen corned beef tempor dolore cupim laboris ut enim pork chop kevin.
      
      Ullamco eiusmod alcatra veniam brisket, ad ipsum venison ea jowl. Officia laboris drumstick bacon, labore duis boudin tempor. Sirloin ut ball tip in corned beef. Officia elit eiusmod, nulla tri-tip swine aliquip. Officia consequat picanha esse in pastrami, biltong reprehende
      """
      TaskyNodeEditor.sharedInstance.updateTaskDescription(for: task, with: taskDescription)
    }
    return randomTaskSet
  }
}
