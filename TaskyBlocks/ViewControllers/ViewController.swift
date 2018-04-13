//
//  ViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-26.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UIScrollViewDelegate
{
  
  var activeTaskySet: Results<TaskyNode>!
  var selectedTask: TaskyNode?
  var realm: Realm!
  var filter = "completionDate == nil"
  
  //MARK - Outlets
  @IBOutlet weak var taskyGraph: TaskyGraphView!
  var tasksData: TaskDataSource?
  
  override func viewDidLoad()
  { super.viewDidLoad()
    taskyGraph.delegate = self
    try! realm = Realm()
    activeTaskySet = realm.objects(TaskyNode.self).filter(filter)
    graphIt()
  }
  
  //  Tells the delegate that zooming of the content in the scroll view is about to commence.
  internal func scrollViewWillBeginZooming(_: UIScrollView, with: UIView?)
  {
  }
  
  //  Tells the delegate when zooming of the content in the scroll view completed.
  internal func scrollViewDidEndZooming(_: UIScrollView, with: UIView?, atScale: CGFloat)
  { print(atScale)
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
  
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    switch segue.identifier
//    { case "priorityToDetail":
//      guard tasksData != nil
//        else
//      { fatalError("TasksData is set to nil")
//      }
//      //selectedTask = tasksData?.newTask()
//      let detailNavController = segue.destination as! UINavigationController
//      let detailViewController = detailNavController.topViewController as! DetailViewController
//      detailViewController.taskDetailDataSource = self
////      detailViewController.tasksData = tasksData
//
//    default:
//      fatalError("performVC Called an unknown segue")
//    }
//  }
  
  override func viewWillAppear(_ animated: Bool)
  { graphIt()
  }
  
  override func didReceiveMemoryWarning()
  { super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func graphIt()
  {

  
    taskyGraph.graphPriorityWith(taskSet: Set.init(activeTaskySet))
    
  }
  //MARK: Actions
  @IBAction func addButton(_ sender: Any)
  {
    realm.beginWrite()
    let task = TaskyNode.init()
    realm.add(task)
    try! realm.commitWrite()
    self.graphIt()
  }
  
  
}

