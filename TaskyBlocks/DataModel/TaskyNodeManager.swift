//
//  TaskyNodeManager.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-11.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift


class TaskyNodeManager: TaskDataSource
{

  var realm: Realm!
  var tasks: Results<TaskyNode>!
  let beHappy: TaskyNode = TaskyNode()
  
  fileprivate var masterActiveTaskSet = Set<TaskyNode>()
  var completedTaskySet: Set<TaskyNode> = []
  
  var activeTaskCount: Int
  {
    return activeTaskySet.count
  }
  
  
  var activeTaskySet: Set<TaskyNode>
  {
    get
    {
      return masterActiveTaskSet
    }
    set (newActiveTaskList)
    {
      masterActiveTaskSet = newActiveTaskList
    }
  }

  func setupProcesses()
  {
    var taskSet: Set<TaskyNode>!
    realm = try! Realm()
    realm.beginWrite()

      createRandomTasks()
      tasks = realm.objects(TaskyNode.self)
      taskSet = Set(tasks)
      TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)  //Only works on QUERIED REALM OBJECTS

    for task in taskSet
    { task.soundOff()
    }
  }
  
  //MARK: Task Creation and Deletion
  func newTask(with name: String = "New Task", and priority: Double = 50) -> TaskyNode
  {
    let task = TaskyNode.init(from: self, with: name, and: priority)
    task.addAsChildTo(newParent: beHappy)
    addToRealm(taskyNode: task)
    return task
  }
  
  func deleteAllHistory()
  {
    realm.deleteAll()
  }
  
  func addToRealm(taskyNode: TaskyNode)
    //try! realm.write
    {
      self.realm.add(taskyNode)
      taskyNode.soundOff()
      updateAllTaskPriorities()
    }

  
  func updateAllTaskPriorities()
  {
    var taskSet: Set<TaskyNode>!
    tasks = realm.objects(TaskyNode.self)
    taskSet = Set(tasks)
    TaskyNode.updatePriorityFor(tasks: taskSet, limit: 100)  //Only works on QUERIED REALM OBJECTS
    for task in taskSet
    { task.soundOff()
    }
  }
  
  func remove(task: TaskyNode)
  { task.prepareRemove()
    masterActiveTaskSet.remove(task)
  }
  
  func setComplete(for task: TaskyNode, on date: Date = Date())
  { task.markAsCompleted(on: date)
    let removedTask = masterActiveTaskSet.remove(task)
    if let uRemovedTask = removedTask
    { completedTaskySet.insert(uRemovedTask)
    }
  }
  
  //MARK: TaskDataSource methods
  
  func serveTaskData() -> Set<TaskyNode>
  { return self.activeTaskySet
  }
  
  //MARK: Data Server methods
  func crucials() -> (Set<TaskyNode>)
  { var crucials: Set<TaskyNode> = []
    for taskyNode in activeTaskySet
    { if taskyNode.priorityApparent > 66
      { crucials.insert(taskyNode)
      }
    }
    return crucials
  }
  
  func primals() -> (Set<TaskyNode>)
  {
    var primals: Set<TaskyNode> = []
    for taskyNode in activeTaskySet
    { if taskyNode.parents.isEmpty == true
      { primals.insert(taskyNode)
      }
    }
    return primals
  }
  
  func randomTask() -> TaskyNode
  { let unsignedIntTerminus = UInt32(self.activeTaskySet.count)
    var taskArray: [TaskyNode] = []
    taskArray.append(contentsOf: self.activeTaskySet)
    guard unsignedIntTerminus < 1
      else
    { fatalError("Error... no tasks in active set")
    }
    let randomInteger = Int(arc4random_uniform(unsignedIntTerminus))
    return taskArray[randomInteger]
  }
  
  func createRandomTasks()
  { realm = try! Realm()
    
    let nodeA = self.newTask()
    let nodeB = self.newTask()
    let nodeC = self.newTask()
    let nodeD = self.newTask()
    let nodeE = self.newTask()
    let nodeF = self.newTask()
    let nodeG = self.newTask()
    let nodeH = self.newTask()
    let nodeI = self.newTask()
    let nodeJ = self.newTask()
    let nodeK = self.newTask()
    let nodeL = self.newTask()
    
    masterActiveTaskSet.insert(nodeA)
    masterActiveTaskSet.insert(nodeB)
    masterActiveTaskSet.insert(nodeC)
    masterActiveTaskSet.insert(nodeD)
    masterActiveTaskSet.insert(nodeE)
    masterActiveTaskSet.insert(nodeF)
    masterActiveTaskSet.insert(nodeG)
    masterActiveTaskSet.insert(nodeH)
    masterActiveTaskSet.insert(nodeI)
    masterActiveTaskSet.insert(nodeJ)
    masterActiveTaskSet.insert(nodeK)
    masterActiveTaskSet.insert(nodeL)
    
    var verbs = ["Eat", "Wash", "Plead With", "Feed", "Buy", "Exercise", "Fluff", "Make", "Cook", "Ponder", "Enable", "Dominate", "Contemplate", "Avoid", "Eliminate", "Flog", "Threaten", "Pacify", "Enrage", "Bewilder", "Frighten", "Placate", "Interrogate", "Moisten", "Shuck", "Wax", "Surveil", "Alarm", "Annoy", "Frustrate", "Telephone", "Buffalo", "Berate", "Seduce"]
    var nouns = ["Dog", "Dishes", "Car", "Neighbors", "Laundry", "Bathroom", "Bills", "Kids", "Boss", "Pool", "Yard", "Garage", "Garden", "Fridge", "Inlaws", "Cat", "Baby", "Shed", "TV", "Light Fixtures", "Neighborhood", "Rent", "China", "Taxes", "Deacon", "Postman", "Telephone", "Buffalo", "Local Urchins", "Garbage"]

    for task in activeTaskySet
    { let verbQty = UInt32(verbs.count)
      let nounQty = UInt32(nouns.count)
      let rand1 = Int(arc4random_uniform(verbQty - 1))
      let rand2 = Int(arc4random_uniform(nounQty - 1))
      let nameString = "\(verbs.remove(at: Int(rand1))) the \(nouns.remove(at: rand2))"
      task.addAsParentTo(newChild: nodeA)
      task.priorityDirect.value = Double(arc4random_uniform(99) + 1)
      task.title = nameString
      task.taskDescription =
      """
      Spicy jalapeno bacon ipsum dolor amet consequat ipsum fugiat jowl ut elit occaecat strip steak. Reprehenderit chuck tempor laborum bresaola dolore irure. Brisket tenderloin esse kielbasa culpa mollit ut. Consectetur in ham pork loin, hamburger burgdoggen corned beef tempor dolore cupim laboris ut enim pork chop kevin.
      
      Ullamco eiusmod alcatra veniam brisket, ad ipsum venison ea jowl. Officia laboris drumstick bacon, labore duis boudin tempor. Sirloin ut ball tip in corned beef. Officia elit eiusmod, nulla tri-tip swine aliquip. Officia consequat picanha esse in pastrami, biltong reprehende
      """
    }
    nodeA.removeAsChildToAll()
    nodeC.addAsChildTo(newParent: nodeB)
    nodeE.addAsConsequentTo(newAntecedent: nodeF)
    nodeF.addAsConsequentTo(newAntecedent: nodeG)
    nodeH.addAsParentTo(newChild: nodeF)
    
    TaskyNode.updatePriorityFor(tasks: activeTaskySet, limit: 100)
    for task in activeTaskySet
    {
      realm.add(task)
    }
  }
}


