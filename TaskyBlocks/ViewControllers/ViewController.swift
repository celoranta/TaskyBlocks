//
//  ViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-26.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UIScrollViewDelegate, TaskDetailDataSource{


  var activeTaskySet: Set<TaskyNode>!
  var selectedTask: TaskyNode?
  var realm: Realm!
  
  func serveTaskData() -> (Set<TaskyNode>)
  { return activeTaskySet
  }

  func returnSelectedTask() -> TaskyNode {
    //This method is an incomplete stub
    print("New Task Returned to Priority VC")
    guard let task = selectedTask
    else
    {
      fatalError("detail view returned a nil task")
    }
    return task
  }
  
  @IBOutlet weak var taskyGraph: TaskyGraphView!
  var tasksData: TaskDataSource?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    taskyGraph.delegate = self
    try! realm = Realm()
    let tasks = realm.objects(TaskyNode.self)
    activeTaskySet = Set(tasks)
    
    graphIt()
  }
  
  //  Tells the delegate that zooming of the content in the scroll view is about to commence.
  internal func scrollViewWillBeginZooming(_: UIScrollView, with: UIView?)
  {
  
  }
  
  //  Tells the delegate when zooming of the content in the scroll view completed.
  internal func scrollViewDidEndZooming(_: UIScrollView, with: UIView?, atScale: CGFloat)
  {
    print(atScale)
  }
  
  //  Tells the delegate that the scroll view’s zoom factor changed.
  
  func scrollViewDidZoom(_: UIScrollView)
  {
    
  }
  
  //
  //  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
  //  {
  //    return taskyGraph
  //  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier
  {
    case "priorityToDetail":
      guard tasksData != nil
        else
      {
        fatalError("TasksData is set to nil")
      }
      //selectedTask = tasksData?.newTask()
      let detailNavController = segue.destination as! UINavigationController
      let detailViewController = detailNavController.topViewController as! DetailViewController
      detailViewController.taskDetailDataSource = self
      detailViewController.tasksData = tasksData
      
      default:
      fatalError("performVC Called an unknown segue")
  }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    graphIt()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func graphIt()
  {
//    guard let tasksDataUnwrapped = tasksData
//      else
//    {
//      fatalError("Data source is nil")
//    }
    let displayTasks = activeTaskySet
    taskyGraph.graphPriorityWith(taskSet: activeTaskySet)
  }
}

