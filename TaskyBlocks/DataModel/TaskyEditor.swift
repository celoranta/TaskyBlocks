//
//  TaskyEditor.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-14.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

enum NewTaskyType {
  case normal, random
}

class TaskyEditor: NSObject {
  private let realm: Realm
  var taskDatabase: Results<Tasky>
  static let sharedInstance = TaskyEditor()
  var notificationToken: NotificationToken? = nil
  
  //MARK: Task Creation
  func newTask() -> Tasky
{
    var newTasky: Tasky!
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
        newTasky = Tasky()
        realm.add(newTasky, update: true)
      }
    case .random:
      let newTaskyArray = createRandomTasks(qty: 1)
      newTasky = newTaskyArray[0]
    }
    //TaskyEditor.sharedInstance.updateAllActivePriorities()
    guard let returnTask = realm.object(ofType: Tasky.self, forPrimaryKey: newTasky.taskId)
      else
    {
      fatalError("Realm returned a non-Task object")
    }
    return returnTask
  }
  
  func delete(task: Tasky) {
    try! realm.write {
    realm.delete(task)
    }
  }
  
  //MARK: Task Editing
  func makePermanent(task: Tasky)
  {
    realm.beginWrite()
    task.isPermanent = 1
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func changeTitle(task: Tasky, to title: String)
  {
    realm.beginWrite()
    task.title = title
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func setEstimatedTime(of task: Tasky, to seconds: Int)
  {
    realm.beginWrite()
    task.secondsEstimated.value = seconds
    try! realm.commitWrite()
  }
  
  func setElapsedTime(of task: Tasky, to seconds: Int)
  {
    realm.beginWrite()
    task.secondsElapsed = seconds
    try! realm.commitWrite()
  }
  
  func setDirectPriority(of task: Tasky, to priority: Double)
  {
    realm.beginWrite()
    task.priorityDirect.value = priority
    realm.add(task, update: true)
    print("Attempting to write new priority to realm")
    try! realm.commitWrite()
  }
  
  func setDirectPriority(of task: Tasky, to priority: Double, withoutUpdating token: NotificationToken)
  {
    realm.beginWrite()
    task.priorityDirect.value = priority
    realm.add(task, update: true)
    print("Attempting to write new priority to realm")
    try! realm.commitWrite(withoutNotifying: [token])
  }
  
  func complete(task: Tasky)
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
  func prepareRemove(task: Tasky)
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
  func updateTaskDescription(for task: Tasky, with text: String)
  {
    realm.beginWrite()
    print("writing to realm")
    task.taskDescription = text
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  //MARK: Tasky Relational Assignment Edits
  
  func add(task: Tasky, AsChildTo newParent: Tasky)
  {
    realm.beginWrite()
    if !task.parents.contains(newParent)
    {
      newParent.children.append(task)
     // task.parents.append(newParent)
      realm.add(newParent, update: true)
    }
    try! realm.commitWrite()
  }
  
  func add(task: Tasky, asParentTo newChild: Tasky)
  {
    realm.beginWrite()
    if !newChild.parents.contains(task)
    {
      //newChild.parents.append(task)
      task.children.append(newChild)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func remove(task: Tasky, asChildTo parent: Tasky)
  {
    realm.beginWrite()
    if let index = task.parents.index(of: parent)
    {
      parent.children.remove(at: index)
      //task.parents.remove(at: index)
      realm.add(parent, update: true)
    }
    try! realm.commitWrite()
  }
  
  func remove(task: Tasky, asParentTo child: Tasky)
  {
    realm.beginWrite()
    if let uindex = child.parents.index(of: task)
    {
      task.children.remove(at: uindex)
     // child.parents.remove(at: uindex)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func removeAsChildToAllParents(task: Tasky)
  {
    realm.beginWrite()
    for parent in task.parents{
      if let index = parent.children.index(of: task) {
        parent.children.remove(at: index)
      }
      realm.add(parent, update: true)
    }
    //realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func removeAsParentToAllChildren(task: Tasky)
  {
    for child in task.children
    {
      remove(task: child, asChildTo: task)
    }
  }
  
  func add(task: Tasky, asConsequentTo newAntecedent: Tasky)
  {
    realm.beginWrite()
    if !task.antecedents.contains(newAntecedent)
    {
      task.antecedents.append(newAntecedent)
      realm.add(task, update: true)
    }
    try! realm.commitWrite()
  }
  
  func add(task: Tasky, asAntecedentTo newConsequent: Tasky)
  {
    TaskyEditor.sharedInstance.add(task: newConsequent, asConsequentTo: task)
  }
  
  func remove(task: Tasky, asConsequentTo antecedent: Tasky)
  {

    if let index = task.antecedents.index(of: antecedent)
    {
          realm.beginWrite()
      task.antecedents.remove(at: index)
      realm.add(task, update: true)
          try! realm.commitWrite()
    }

  }
  
  func remove(task: Tasky, asAntecedentTo consequent: Tasky)
  {
    TaskyEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
  }
  
  func removeAsConsequentToAll(task: Tasky)
  {
    realm.beginWrite()
    task.antecedents.removeAll()
    realm.add(task, update: true)
    try! realm.commitWrite()
  }
  
  func removeAsAntecedentToAll(task: Tasky)
  {
    for consequent in task.consequents
    {
      TaskyEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
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
    self.taskDatabase = realm.objects(Tasky.self)
    print("Database created in memory")
    super.init()
  }
  
  deinit
  {
    print("editor deinitialization:")
    print("Saved changes and closed write session")
    print("Realm instance closed")
  }
  
  func createRandomTasks(qty: Int = 1) -> [Tasky]
  {
    var randomTaskSet: [Tasky] = []
    for _ in 0..<qty
    {
      let newTasky = Tasky()
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
      TaskyEditor.sharedInstance.setDirectPriority(of: task, to: randomPriority)
      TaskyEditor.sharedInstance.changeTitle(task: task, to: nameString)
      let taskDescription =
      """
      Spicy jalapeno bacon ipsum dolor amet consequat ipsum fugiat jowl ut elit occaecat strip steak. Reprehenderit chuck tempor laborum bresaola dolore irure. Brisket tenderloin esse kielbasa culpa mollit ut.
      """
      TaskyEditor.sharedInstance.updateTaskDescription(for: task, with: taskDescription)
    }
    return randomTaskSet
  }
  
  func setupDatabaseIfRequired()
  {
    if TaskyEditor.sharedInstance.taskDatabase.count == 0
    {
      let testNewTask = TaskyEditor.sharedInstance.newTask()
      TaskyEditor.sharedInstance.makePermanent(task: testNewTask)
      TaskyEditor.sharedInstance.changeTitle(task: testNewTask, to: "Be Happy")
      TaskyEditor.sharedInstance.setDirectPriority(of: testNewTask, to: 100.00)
      TaskyEditor.sharedInstance.complete(task: testNewTask)
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
      for task in taskDatabase
      {
        notificationToken?.invalidate()
        TaskyEditor.sharedInstance.complete(task: task)
      }
      
    }
  }
  
  func countActiveTasks() -> Int {
    let returnCount: Int = taskDatabase.filter({$0.completionDate == nil}).count
    return returnCount
  }
  
  func rootTasks() -> [Tasky] {
    let rootTaskArray: [Tasky] = Array(taskDatabase.filter({$0.isPrimal == true}))
    return rootTaskArray
  }
}
