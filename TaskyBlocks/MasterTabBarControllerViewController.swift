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
}

class MasterTabBarControllerViewController: UITabBarController, UITabBarControllerDelegate,  TaskDataSource {
  
  var activeTaskySet: Set<TaskyNode> = []
  
  enum relative
  {
    case ancestors, descendants, brethren
  }
  
  enum relationalScheme
  {
    case all, mostDistant, immediate
  }
  
  enum relationErrors
  {
    case selfReference
  }
  
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
      nodeD.parents.insert(nodeA, at: 0)
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
        task.priorityOverride = Double(arc4random_uniform(99) + 1)
        nodeK.priorityOverride = nodeA.priorityOverride
        nodeB.priorityOverride = nodeC.priorityOverride
        task.taskDescription =
        """
        Spicy jalapeno bacon ipsum dolor amet consequat ipsum fugiat jowl ut elit occaecat strip steak. Reprehenderit chuck tempor laborum bresaola dolore irure. Brisket tenderloin esse kielbasa culpa mollit ut. Consectetur in ham pork loin, hamburger burgdoggen corned beef tempor dolore cupim laboris ut enim pork chop kevin.
        
        Ullamco eiusmod alcatra veniam brisket, ad ipsum venison ea jowl. Officia laboris drumstick bacon, labore duis boudin tempor. Sirloin ut ball tip in corned beef. Officia elit eiusmod, nulla tri-tip swine aliquip. Officia consequat picanha esse in pastrami, biltong reprehende
        """
      }
      
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
