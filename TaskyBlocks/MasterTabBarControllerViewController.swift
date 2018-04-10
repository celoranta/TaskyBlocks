//
//  MasterTabBarControllerViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-06.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol TaskDataSource {
  
  var activeTaskySet: Set<TaskyNode>
  {
    get
    set
  }
  
  func serveTaskData() -> (Set<TaskyNode>)
    func crucials() -> (Set<TaskyNode>)
    func primals() -> (Set<TaskyNode>)
  func newTask() -> TaskyNode
  func remove(task: TaskyNode)
    func setComplete(for task: TaskyNode, on date: Date)
}

class MasterTabBarControllerViewController: UITabBarController, UITabBarControllerDelegate,  TaskDataSource {
  
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
  
  fileprivate var masterActiveTaskSet = Set<TaskyNode>()
  var completedTaskySet: Set<TaskyNode> = []
  var activeTaskCount: Int
  {
   return activeTaskySet.count
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createRandomTasks()
    self.delegate = self
    
    if let unwrappedViewControllers = self.viewControllers
    {
      if let unwrappedViewController = unwrappedViewControllers[0] as? ViewController
      {
        unwrappedViewController.tasksData = self
      }
      if let unwrappedViewController = unwrappedViewControllers[0] as? PomodoroViewController
      {
        unwrappedViewController.tasksData = self
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //MARK: Task Creation and Deletion
  
  func newTask() -> TaskyNode
  {
    let task = TaskyNode()
    masterActiveTaskSet.insert(task)
    return task
  }
  
  func remove(task: TaskyNode)
  {
    task.prepareRemove()
    masterActiveTaskSet.remove(task)
  }
  
  func setComplete(for task: TaskyNode, on date: Date = Date())
  {
    task.markAsCompleted(on: date)
    let removedTask = masterActiveTaskSet.remove(task)
    if let uRemovedTask = removedTask
    {
      completedTaskySet.insert(uRemovedTask)
    }
  }
  
  //MARK: TaskDataSource methods
  
  func serveTaskData() -> Set<TaskyNode> {
    return self.activeTaskySet
  }
  
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if let selectedViewController = viewController as? ViewController
    {
      selectedViewController.tasksData = self
    }
    if let selectedViewController = viewController as? PomodoroViewController
    {
      selectedViewController.tasksData = self
    }
    return true
  }
  
  func crucials() -> (Set<TaskyNode>)
  {
    var crucials: Set<TaskyNode> = []
    for taskyNode in activeTaskySet
    {
      if taskyNode.priorityApparent > 66
      {
        crucials.insert(taskyNode)
      }
    }
    return crucials
  }
  
  func primals() -> (Set<TaskyNode>)
  {
    var primals: Set<TaskyNode> = []
    for taskyNode in activeTaskySet
    {
      if taskyNode.parents.isEmpty == true
      {
        primals.insert(taskyNode)
      }
    }
    return primals
  }
  
  func randomTask() -> TaskyNode
  {
    let unsignedIntTerminus = UInt32(self.activeTaskySet.count)
    var taskArray: [TaskyNode] = []
    taskArray.append(contentsOf: self.activeTaskySet)
    guard unsignedIntTerminus < 1
      else
    {
      fatalError("Error... no tasks in active set")
    }
    let randomInteger = Int(arc4random_uniform(unsignedIntTerminus))
    return taskArray[randomInteger]
  }
  
  func createRandomTasks()
  {
  let nodeA = TaskyNode()
  let nodeB = TaskyNode()
  let nodeC = TaskyNode()
  let nodeD = TaskyNode()
  let nodeE = TaskyNode()
  let nodeF = TaskyNode()
  let nodeG = TaskyNode()
  let nodeH = TaskyNode()
  let nodeI = TaskyNode()
  let nodeJ = TaskyNode()
  let nodeK = TaskyNode()
  let nodeL = TaskyNode()
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
  {
  
  let verbQty = UInt32(verbs.count)
  let nounQty = UInt32(nouns.count)
  let rand1 = Int(arc4random_uniform(verbQty - 1))
  let rand2 = Int(arc4random_uniform(nounQty - 1))
  let nameString = "\(verbs.remove(at: Int(rand1))) the \(nouns.remove(at: rand2))"
  //task.addAsChildTo(newParent: nodeA)
  task.priorityDirect = Double(arc4random_uniform(99) + 1)
  task.title = nameString
  task.taskDescription =
  """
  Spicy jalapeno bacon ipsum dolor amet consequat ipsum fugiat jowl ut elit occaecat strip steak. Reprehenderit chuck tempor laborum bresaola dolore irure. Brisket tenderloin esse kielbasa culpa mollit ut. Consectetur in ham pork loin, hamburger burgdoggen corned beef tempor dolore cupim laboris ut enim pork chop kevin.
  
  Ullamco eiusmod alcatra veniam brisket, ad ipsum venison ea jowl. Officia laboris drumstick bacon, labore duis boudin tempor. Sirloin ut ball tip in corned beef. Officia elit eiusmod, nulla tri-tip swine aliquip. Officia consequat picanha esse in pastrami, biltong reprehende
  """
  }
  
  //nodeA.removeAsChildToAll()
  //nodeK.priorityOverride = nodeA.priorityOverride
  //nodeB.priorityOverride = nodeC.priorityOverride
  //nodeC.addAsChildTo(newParent: nodeB)
  // nodeE.addAsConsequentTo(newAntecedent: nodeF)
  //nodeF.addAsConsequentTo(newAntecedent: nodeG)
  
  
  TaskyNode.updatePriorityFor(tasks: activeTaskySet, limit: 100)
  // Do any additional setup after loading the view.
}
}
