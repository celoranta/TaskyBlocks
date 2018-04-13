//
//  ViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-26.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate
{
  
  var activeTaskySet: Results<TaskyNode>!
  var selectedTask: TaskyNode?
  var realm: Realm!
  var filter = "completionDate == nil"
  
  //MARK - Outlets
  @IBOutlet weak var taskyGraph: TaskyGraphView!
  
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

  
  override func viewWillAppear(_ animated: Bool)
  { graphIt()
  }
  
  override func didReceiveMemoryWarning()
  { super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func graphIt()
  {
    taskyGraph.graphPriority()
  }
  
  //MARK: Actions
  @IBAction func addButton(_ sender: Any)
  {
    let _ = TaskyNode.init(forUse: true)
    self.graphIt()
  }
  
  @IBAction func pinch(_ sender: Any) {
    print("Ouch!  A Pinch!")
    let pinchObject = sender as! UIPinchGestureRecognizer
    print(pinchObject.scale)
    print(pinchObject.velocity)
    print(pinchObject.location(in: self.view))
    print(pinchObject.numberOfTouches)
  }
}

