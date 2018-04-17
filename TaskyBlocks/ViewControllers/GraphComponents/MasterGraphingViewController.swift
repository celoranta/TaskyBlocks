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
  let filter = "completionDate == nil"
  let blockyAlpha: CGFloat = 0.75
  var blockyWidth: CGFloat = 123.5
  let layout = MasterGraphingCollectionViewLayout()
  //var subscription: NotificationToken?
  let borderColor = UIColor.darkGray.cgColor
  let highlightBorderColor = UIColor.yellow.cgColor
  var selectedTask: TaskyNode!
  //var collectionView = UICollectionView()
  fileprivate var longPressGesture: UILongPressGestureRecognizer!
  var blockyBorder: CGFloat
  {
    get
    {
      return blockyHeight * 0.05
    }
  }
  var blockyRadius: CGFloat
  {
    get
    {
      return blockyHeight * 0.2
    }
  }
  var blockyHeight: CGFloat
  {
    get
    {
      return blockyWidth * 0.5
    }
  }
  var blockSize: CGSize
  {
    get
    {
      return CGSize.init(width: blockyWidth, height: blockyHeight
      )
    }
  }

  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var deleteButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    layout.delegate = self
    //layout.itemSize = blockSize
    //layout.estimatedItemSize = CGSize.init(width: 500, height: 500)
    //layout.minimumInteritemSpacing = 2
    //layout.minimumLineSpacing = 2
    //layout.sectionInset = .init(top: blockyHeight, left: blockyHeight, bottom: blockyWidth, right: blockyWidth)
    collectionView.collectionViewLayout = layout
    activeTaskySet = TaskyNodeEditor.sharedInstance.database.filter(self.filter)
    //deleteButton.isEnabled = false
    self.navigationController?.toolbar.isHidden = false
    //collectionView.minimumZoomScale = 0.5
    //collectionView.maximumZoomScale = 6.0
    //collectionView.isUserInteractionEnabled = true
    
    //for dragging
    self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
    
    //var pinchGesture = UIPinchGestureRecognizer()
    
    
    
    collectionView.addGestureRecognizer(longPressGesture)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    TaskyNode.updatePriorityFor(tasks: Set.init(TaskyNodeEditor.sharedInstance.database.filter(self.filter)),limit: 100)
    collectionView.reloadData()
    if let nav = self.navigationController {
      nav.isToolbarHidden = false
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
 // MARK: Layout Tutorial method
  func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
    //let randomHeight = Double((arc4random_uniform(3) + 1) * 100)
    return CGFloat.init(blockyHeight)
  }
  
  //MARK:  Realm notification
  
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
      cell.layer.borderColor = borderColor
//    }
    
    cell.cellTitleLabel.text = task.title
    
    //let taskyLabel = UILabel.init(frame: cell.bounds)
    //let taskyBlock = UIView()
    
    //cell.addSubview(taskyBlock)
    //taskyBlock.addSubview(taskyLabel)
    //taskyBlock.color = UIColor.clear

    
    //taskyBlock.frame.size = cell.frame.size
    cell.alpha = blockyAlpha
    cell.backgroundColor = UIColor.clear
    cell.autoresizesSubviews = true
    
    cell.layer.borderWidth = blockyBorder
    cell.layer.cornerRadius = blockyRadius
    cell.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
    cell.autoresizesSubviews = true
    
    cell.cellTitleLabel.frame = cell.bounds
    cell.cellTitleLabel.frame.size.width = blockyWidth
    cell.cellTitleLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    cell.cellTitleLabel.text = "\(task.title)"//"\(task.priorityApparent)"
    cell.cellTitleLabel.textAlignment = .center
    cell.cellTitleLabel.numberOfLines = 0
    cell.cellTitleLabel.lineBreakMode = .byWordWrapping
    cell.cellTitleLabel.font.withSize(blockyWidth / 12)
    
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
