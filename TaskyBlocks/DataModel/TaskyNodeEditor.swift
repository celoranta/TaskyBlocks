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
      try! realm.write
      {
        newTaskyNode = TaskyNode()
        realm.add(newTaskyNode, update: true)
      }
    case .random:
      let newTaskyNodeArray = createRandomTasks(qty: 1)
      newTaskyNode = newTaskyNodeArray[0]
    }
    //TaskyNodeEditor.sharedInstance.updateAllActivePriorities()
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
    print("Attempting to write new priority to realm")
    try! realm.commitWrite()
  }
  
  func complete(task: TaskyNode)
  {
    if task.isPermanent != 1
    {
      prepareRemove(task: task)
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
    {
      for child in task.children
      {
        add(task: child, AsChildTo: parent)
      }
    }
    for antecedent in task.antecedents
    {
      for consequent in task.consequents
      {
        add(task: consequent, asConsequentTo: antecedent)
      }
    }
    removeAsAntecedentToAll(task: task)
    removeAsConsequentToAll(task: task)
    removeAsParentToAllChildren(task: task)
    removeAsChildToAllParents(task: task)
  }
  
  //MARK: Task Description
  func updateTaskDescription(for task: TaskyNode, with text: String)
  {
    realm.beginWrite()
    print("writing to realm")
    task.taskDescription = text
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  //MARK: TaskyNode Relational Assignment Edits
  
  func add(task: TaskyNode, AsChildTo newParent: TaskyNode)
  {
    realm.beginWrite()
    if !task.parents.contains(newParent)
    {
      task.parents.append(newParent)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func add(task: TaskyNode, asParentTo newChild: TaskyNode)
  {
    realm.beginWrite()
    if !newChild.parents.contains(task)
    {
      newChild.parents.append(task)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func remove(task: TaskyNode, asChildTo parent: TaskyNode)
  {
    realm.beginWrite()
    if let index = task.parents.index(of: parent)
    {
      task.parents.remove(at: index)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func remove(task: TaskyNode, asParentTo child: TaskyNode)
  {
    realm.beginWrite()
    if let uindex = child.parents.index(of: task)
    {
      child.parents.remove(at: uindex)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func removeAsChildToAllParents(task: TaskyNode)
  {
    realm.beginWrite()
    task.parents.removeAll()
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func removeAsParentToAllChildren(task: TaskyNode)
  {
    for child in task.children
    {
      remove(task: child, asChildTo: task)
    }
  }
  
  func add(task: TaskyNode, asConsequentTo newAntecedent: TaskyNode)
  {
    realm.beginWrite()
    if !task.antecedents.contains(newAntecedent)
    {
      task.antecedents.append(newAntecedent)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func add(task: TaskyNode, asAntecedentTo newConsequent: TaskyNode)
  {
    TaskyNodeEditor.sharedInstance.add(task: newConsequent, asConsequentTo: task)
  }
  
  func remove(task: TaskyNode, asConsequentTo antecedent: TaskyNode)
  {

    if let index = task.antecedents.index(of: antecedent)
    {
          realm.beginWrite()
      task.antecedents.remove(at: index)
      realm.add(task, update: true)
          try! realm.commitWrite()
    }

  }
  
  func remove(task: TaskyNode, asAntecedentTo consequent: TaskyNode)
  {
    TaskyNodeEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
  }
  
  func removeAsConsequentToAll(task: TaskyNode)
  {
    realm.beginWrite()
    task.antecedents.removeAll()
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func removeAsAntecedentToAll(task: TaskyNode)
  {
    for consequent in task.consequents
    {
      TaskyNodeEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
    }
  }
  
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
  }
  
  deinit
  {
    print("editor deinitialization:")
    print("Saved changes and closed write session")
    print("Realm instance closed")
  }
  
  func createRandomTasks(qty: Int = 1) -> [TaskyNode]
  {
    var randomTaskSet: [TaskyNode] = []
    for _ in 0..<qty
    {
      let newTasky = TaskyNode()
      randomTaskSet.append(newTasky)
    }
    var verbs = ["Eat", "Wash", "Plead With", "Feed", "Buy", "Exercise", "Fluff", "Make", "Cook", "Ponder", "Enable", "Dominate", "Contemplate", "Avoid", "Eliminate", "Flog", "Threaten", "Pacify", "Enrage", "Bewilder", "Frighten", "Placate", "Interrogate", "Moisten", "Shuck", "Wax", "Surveil", "Alarm", "Annoy", "Frustrate", "Telephone", "Buffalo", "Berate", "Seduce", "Scrub", "Consider", "Suffer", "Confusticate", "Disregard", "Dismiss", "Embrace", "Embolden"]
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
      Spicy jalapeno bacon ipsum dolor amet consequat ipsum fugiat jowl ut elit occaecat strip steak. Reprehenderit chuck tempor laborum bresaola dolore irure. Brisket tenderloin esse kielbasa culpa mollit ut.
      """
      TaskyNodeEditor.sharedInstance.updateTaskDescription(for: task, with: taskDescription)
    }
    return randomTaskSet
  }
  
  func setupDatabaseIfRequired()
  {
    if TaskyNodeEditor.sharedInstance.database.count == 0
    {
      let testNewTask = TaskyNodeEditor.sharedInstance.newTask()
      TaskyNodeEditor.sharedInstance.makePermanent(task: testNewTask)
      TaskyNodeEditor.sharedInstance.changeTitle(task: testNewTask, to: "Be Happy")
      TaskyNodeEditor.sharedInstance.setDirectPriority(of: testNewTask, to: 100.00)
      TaskyNodeEditor.sharedInstance.complete(task: testNewTask)
      print("\nNew primal value created: ")
      testNewTask.soundOff()
      
      let userSettings = UserDefaults()
      let settingsExist = userSettings.bool(forKey: "DefaultsPreviouslyLoaded")
      if settingsExist == false
      {
        self.configureInitialUserDefaults()
      }
    }
  }
  
  fileprivate func configureInitialUserDefaults()
  {
    let userSettings = UserDefaults()
    userSettings.set(false, forKey: "NewTasksAreRandom")
    userSettings.set(true, forKey: "DefaultsPreviouslyLoaded")
  }
  
  func deleteDatabase()
  {
    try! realm.write
    {
      for task in database
      {
        notificationToken?.invalidate()
        TaskyNodeEditor.sharedInstance.complete(task: task)
      }
      
    }
  }
}
