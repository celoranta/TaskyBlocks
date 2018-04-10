//
//  MasterTabBarControllerViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-06.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol TaskDataSource {
  func serveTaskData() -> (Set<TaskyNode>)
    func crucials() -> (Set<TaskyNode>)
    func primals() -> (Set<TaskyNode>)
  func newTask() -> TaskyNode
  func remove(task: TaskyNode)
    func setComplete(for task: TaskyNode, on date: Date)
}

//enum relation
//{case ancestors, descendants, brethren}
//
//enum dependency
//{case dependents, dependees}
//
//enum relativePriority
//{case greater, lesser, equal}
//
//enum relationalScheme
//{case all, mostDistant, immediate}
//
//enum relationErrors
//{case selfReference}


class MasterTabBarControllerViewController: UITabBarController, UITabBarControllerDelegate,  TaskDataSource {
  
  var activeTaskySet: Set<TaskyNode> = []
  var completedTaskySet: Set<TaskyNode> = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
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
      activeTaskySet.insert(nodeA)
      activeTaskySet.insert(nodeB)
      activeTaskySet.insert(nodeC)
      activeTaskySet.insert(nodeD)
      activeTaskySet.insert(nodeE)
      activeTaskySet.insert(nodeF)
      activeTaskySet.insert(nodeG)
      activeTaskySet.insert(nodeH)
      activeTaskySet.insert(nodeI)
      activeTaskySet.insert(nodeJ)
      activeTaskySet.insert(nodeK)
      activeTaskySet.insert(nodeL)
    

      for task in activeTaskySet
      {
        let verbs = ["Eat", "Wash", "Plead With", "Feed", "Buy", "Exercise", "Fluff", "Make", "Cook", "Ponder", "Enable", "Dominate", "Contemplate", "Avoid", "Eliminate", "Flog", "Threaten", "Pacify", "Enrage", "Bewilder", "Frighten", "Placate"]
        let nouns = ["Dog", "Dishes", "Car", "Neighbors", "Laundry", "Bathroom", "Bills", "Kids", "Boss", "Pool", "Yard", "Garage", "Garden", "Fridge", "Inlaws", "Cat", "Baby", "Shed", "TV", "Light Fixtures"]
        let verbQty = UInt32(verbs.count)
        let nounQty = UInt32(nouns.count)
        let rand1 = Int(arc4random_uniform(verbQty - 1))
        let rand2 = Int(arc4random_uniform(nounQty - 1))
        let nameString = "\(verbs[rand1]) the \(nouns[rand2])"
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
    
    //ensure all embedded view controllers with task data sources are assigned a source.
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
    // Dispose of any resources that can be recreated.
  }
  
  //MARK: Task Creation and Deletion
  
  func newTask() -> TaskyNode
  {
    let task = TaskyNode()
    activeTaskySet.insert(task)
    return task
  }
  
  func remove(task: TaskyNode)
  {
    task.prepareRemove()
    activeTaskySet.remove(task)
  }
  
  func setComplete(for task: TaskyNode, on date: Date = Date())
  {
    task.markAsCompleted(on: date)
    let removedTask = activeTaskySet.remove(task)
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
}
