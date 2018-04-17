//
//  MasterGraphingViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-13.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class MasterGraphingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TaskDetailDataSource, TaskyGraphingDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

  //var realm: Realm!
  var activeTaskySet: Results<TaskyNode>!
  var filter = "completionDate == nil"
  let blockyAlpha: CGFloat = 0.75
  var layout = MasterGraphingCollectionViewLayout()

  let highlightBorderColor = UIColor.yellow.cgColor
  var selectedTask: TaskyNode!
  fileprivate var longPressGesture: UILongPressGestureRecognizer!


//  var blockSize: CGSize
//  {get
//    {return CGSize.init(width: blockyWidth, height: blockyHeight)
//    }
//  }

  //MARK: Outlets
  @IBOutlet weak var collectionView: UICollectionView!

  override func viewDidLoad()
  {
    super.viewDidLoad()
    layout.delegate = self
    collectionView.collectionViewLayout = layout
    activeTaskySet = TaskyNodeEditor.sharedInstance.database.filter(self.filter)
    self.navigationController?.toolbar.isHidden = false
    
    //for dragging
    self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
    collectionView.addGestureRecognizer(longPressGesture)
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
    TaskyNode.updatePriorityFor(tasks: Set.init(TaskyNodeEditor.sharedInstance.database.filter(self.filter)),limit: 100)
    collectionView.reloadData()
    if let nav = self.navigationController {
      nav.isToolbarHidden = false
    }
  }
  
 // MARK: Layout Tutorial method
  func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
  {
    //set cell height here
    return CGFloat(MasterGraphingCollectionViewCell.blockyHeight)
  }
  
  //MARK: Collection View
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return activeTaskySet.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "masterCollectionCell", for: indexPath) as! MasterGraphingCollectionViewCell
    let task = activeTaskySet[indexPath.row]
    
//    if cell.isSelected
//    {
//      cell.layer.borderColor = highlightBorderColor
//    }
//    else
//    {

//    }
    
    cell.cellTitleLabel.text = task.title
    cell.alpha = blockyAlpha
    cell.cellTitleLabel.frame.size.width = MasterGraphingCollectionViewCell.blockyWidth
    cell.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
       cell.cellTitleLabel.text = "\(task.title)"//"\(task.priorityApparent)"
    

    
    return cell
  }
  
//  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//  {
//    print(indexPath)
//
//    let newSelectedTask = activeTaskySet[indexPath[1]]
//    let dataSetCell: UICollectionViewCell? = collectionView.cellForItem(at: indexPath)
//
//    print(newSelectedTask.title)
//    if let newSelectedTask = selectedTask
//    {
//      selectedTask = newSelectedTask
//      dataSetCell?.layer.borderColor = highlightBorderColor
//      print("was selected")
//      //TaskyNodeEditor.sharedInstance.complete(task: selectedTask)
//      //performSegue(withIdentifier: "priorityToDetail", sender: self)
//      //DispatchQueue.main.async(execute: {)
//      self.collectionView.reloadData()
//
//    }
//    else
//    {
//      selectedTask = nil
//      dataSetCell?.layer.borderColor = borderColor
//      print("was deselected")
//  }
//  }
//  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
//  {
//    let dataSetCell: UICollectionViewCell? = collectionView.cellForItem(at: indexPath)
//    dataSetCell?.layer.borderColor = borderColor
//    self.collectionView.reloadData()
//  }
  
  //MARK: Drag items
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    let task = activeTaskySet[indexPath.row]
    if task.isPermanent != 1
    {
      return true
    }
    else
    {
      return false
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    print("drag began at \(sourceIndexPath) and ended at \(destinationIndexPath)")
  }
  @objc func handleLongGesture(gesture: UILongPressGestureRecognizer)
  {
    switch(gesture.state)
    {
    case .began:
      guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
        break
      }
      collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
    case .changed:
      collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
    case .ended:
      collectionView.endInteractiveMovement()
    default:
      collectionView.cancelInteractiveMovement()
    }
  }
  
  //MARK:  Zoom
//  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//  return collectionView
//  }
  
  //MARK: Actions
  @IBAction func addButton(_ sender: Any)
  {
    let userSettings = UserDefaults()
    let random = userSettings.bool(forKey: "NewTasksAreRandom")
    switch random
    {
    case false:
      _ = TaskyNodeEditor.sharedInstance.newTask()
    case true:
      _ = TaskyNodeEditor.sharedInstance.createRandomTasks(qty: 1)
    }
    let dataset = Set.init(TaskyNodeEditor.sharedInstance.database.filter(filter))
    TaskyNode.updatePriorityFor(tasks: dataset, limit: 100)
    self.collectionView.reloadData()
  }
  
  //MARK: Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier
    {
    case "priorityToDetail":
      print("prepare for segue to detail with \(selectedTask.title) selected was called")
      let detailVC = segue.destination.childViewControllers.first as! DetailViewController
      detailVC.taskDetailDataSource = self as TaskDetailDataSource
      detailVC.task = selectedTask
    default:
      return
    }
  }
  
  //Task Detail View Delegate
  func returnSelectedTask() -> TaskyNode {
    return selectedTask
  }
}
