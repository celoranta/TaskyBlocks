//
//  TaskyNodeEditor.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-14.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift


class TaskyNodeEditor: NSObject {

  private let realm: Realm
  let database: Results<TaskyNode>
  static let sharedInstance = TaskyNodeEditor()

  //MARK: Task Creation
  func newTask() -> TaskyNode
  {
    let newTaskyNode = TaskyNode()
    realm.add(newTaskyNode)
    self.saveChanges()
    guard let returnedTask = realm.object(ofType: TaskyNode.self, forPrimaryKey: newTaskyNode.taskId)
      else
    {
      fatalError("Realm returned a non-task object")
    }
    return returnedTask
  }
  
  //MARK: Task Editing
  func makePermanent(task: TaskyNode)
  {
    task.isPermanent = 1
    realm.add(task, update: true)
    self.saveChanges()
  }
  
  func changeTitle(task: TaskyNode, to title: String)
  {
    task.title = title
    realm.add(task, update: true)
    self.saveChanges()
  }
  
  func setDirectPriority(of task: TaskyNode, to priority: Double)
  {
    task.priorityDirect.value = priority
    realm.add(task, update: true)
    self.saveChanges()
  }
  
  func complete(task: TaskyNode)
  {
    if task.isPermanent != 1
    {
    task.completionDate = Date()
    realm.add(task, update: true)
    saveChanges()
    print("Tasky node \(task.title) with id: \(task.taskId) was marked complete")
    }
    else
    {
      print("Tasky node \(task.title) with id: \(task.taskId) is permanent and cannot be marked complete")
    }
  }
  
  //MARK: Task Removal prep
  
  func prepareRemove(task: TaskyNode)
  { for parent in task.parents
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
    task.taskDescription = text
    realm.add(task, update: true)
    saveChanges()
  }
  

  //MARK: TaskyNode Relational Assignment Edits
  
  func add(task: TaskyNode, AsChildTo newParent: TaskyNode)
  { if !task.parents.contains(newParent)
  { task.parents.append(newParent)
    realm.add(task, update: true)
    saveChanges()
    }
  }
  
  func add(task: TaskyNode, asParentTo newChild: TaskyNode)
  { if !newChild.parents.contains(task)
  { newChild.parents.append(task)
    realm.add(task, update: true)
    self.saveChanges()
    }
  }
  
  func remove(task: TaskyNode, asChildTo parent: TaskyNode)
  { if let index = task.parents.index(of: parent)
  { task.parents.remove(at: index)
    realm.add(task, update: true)
    self.saveChanges()
    }
  }
  
  func remove(task: TaskyNode, asParentTo child: TaskyNode)
  { if !child.parents.contains(task)
  { child.parents.append(task)
    realm.add(task, update: true)
    self.saveChanges()
    }
  }
  
  func removeAsChildToAllParents(task: TaskyNode)
  { task.parents.removeAll()
    realm.add(task, update: true)
    self.saveChanges()
  }
  
  func removeAsParentToAllChildren(task: TaskyNode)
  { for child in task.children
  { remove(task: child, asChildTo: task)
    realm.add(task, update: true)
    self.saveChanges()
    }
  }
  
  func add(task: TaskyNode, asConsequentTo newAntecedent: TaskyNode)
  { if !task.antecedents.contains(newAntecedent)
  { task.antecedents.append(newAntecedent)
    realm.add(task, update: true)
    self.saveChanges()
    }
  }
  
  func add(task: TaskyNode, asAntecedentTo newConsequent: TaskyNode)
  {
    TaskyNodeEditor.sharedInstance.add(task: newConsequent, asConsequentTo: task)
    realm.add(task, update: true)
    self.saveChanges()
  }
  
  func remove(task: TaskyNode, asConsequentTo antecedent: TaskyNode)
  { if let index = task.antecedents.index(of: antecedent)
  { task.antecedents.remove(at: index)
    realm.add(task, update: true)
    self.saveChanges()
    }
  }
  
  func remove(task: TaskyNode, asAntecedentTo consequent: TaskyNode)
  {
    TaskyNodeEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
    realm.add(task, update: true)
    self.saveChanges()
  }
  
  func removeAsConsequentToAll(task: TaskyNode)
  { task.antecedents.removeAll()
    realm.add(task, update: true)
    self.saveChanges()
  }
  
  func removeAsAntecedentToAll(task: TaskyNode)
  { for consequent in task.consequents
  {
    TaskyNodeEditor.sharedInstance.remove(task: consequent, asConsequentTo: task)
    realm.add(task, update: true)
    self.saveChanges()
    }
  }

  //MARK: Write session management
  private func saveChanges()
  {
    try! realm.commitWrite()
    print("Write session committed")
    realm.beginWrite()
    print("New write session opened")
    // call update priorities here
  }
  
  private func abandonChanges()
  {
    realm.cancelWrite()
    print("Write session abandoned")
    realm.beginWrite()
    print("New write session opened")
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
    realm.beginWrite()
    print("New write session begun")
  }

  deinit
  {
    try! realm.commitWrite()
    print("editor deinitialization:")
    print("Saved changes and closed write session")
    print("Realm instance closed")
  }
  
  func createRandomTasks(qty: Int)
  {
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
      realm.add(task, update: true)
      let verbQty = UInt32(verbs.count)
      let nounQty = UInt32(nouns.count)
      let rand1 = Int(arc4random_uniform(verbQty - 1))
      let rand2 = Int(arc4random_uniform(nounQty - 1))
      let nameString = "\(verbs.remove(at: Int(rand1))) the \(nouns.remove(at: rand2))"
      let randomPriority = Double(arc4random_uniform(99) + 1)
      TaskyNodeEditor.sharedInstance.setDirectPriority(of: task, to: randomPriority)
      TaskyNodeEditor.sharedInstance.changeTitle(task: task, to: nameString)
      let taskDescription =
      """
      Spicy jalapeno bacon ipsum dolor amet consequat ipsum fugiat jowl ut elit occaecat strip steak. Reprehenderit chuck tempor laborum bresaola dolore irure. Brisket tenderloin esse kielbasa culpa mollit ut. Consectetur in ham pork loin, hamburger burgdoggen corned beef tempor dolore cupim laboris ut enim pork chop kevin.
      
      Ullamco eiusmod alcatra veniam brisket, ad ipsum venison ea jowl. Officia laboris drumstick bacon, labore duis boudin tempor. Sirloin ut ball tip in corned beef. Officia elit eiusmod, nulla tri-tip swine aliquip. Officia consequat picanha esse in pastrami, biltong reprehende
      """
   TaskyNodeEditor.sharedInstance.updateTaskDescription(for: task, with: taskDescription)

    }
    
    saveChanges()
  }
}
