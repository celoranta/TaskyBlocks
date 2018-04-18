//
//  MasterGraphingViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-13.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class MasterGraphingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TaskyGraphingDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, TaskDetailDataSource
{
  //MARK: Dependency Injection / Override Properies
  var customLayout = MasterGraphingCollectionViewLayout()
  var filter = "completionDate == nil"
  var sorter = ""
  
  //MARK: Static Properties
  var collectionView: UICollectionView!
  var activeTaskySet: Results<TaskyNode>!
  var selectedTask: TaskyNode!
  let blockyAlpha: CGFloat = 0.75
  let highlightBorderColor = UIColor.yellow.cgColor
  var cellTitleLabel: UILabel!
  let borderColor = UIColor.darkGray.cgColor
  var blockyWidth: CGFloat = 123.5
  var nextViewController: UIViewController? = nil
  var nextViewControllerId: String?
  let newPlusImage = UIImage.init(named: "greyPlus")
  
  fileprivate var longPressGesture: UILongPressGestureRecognizer!
  
  //MARK: CalculatedProperties
  var blockyHeight: CGFloat
  {
    get
    {
      return blockyWidth * 0.5
    }
  }
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
  
  let rightBarButtonItem: UIBarButtonItem =
  {
    let barButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: nil)
    barButtonItem.tintColor = UIColor.blue
    return barButtonItem
  }()
  
  let settingsButton: UIBarButtonItem =
  {
    let barButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: nil)
    barButtonItem.tintColor = UIColor.blue
    return barButtonItem
  }()
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    
    collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: customLayout)
    self.view.addSubview(collectionView)
    collectionView.register(MasterGraphingCollectionViewCell.self, forCellWithReuseIdentifier: "masterCollectionCell")
    collectionView.backgroundColor = UIColor.white
    customLayout.delegate = self
    collectionView.delegate = self
    collectionView.dataSource = self
    activeTaskySet = TaskyNodeEditor.sharedInstance.database.filter(self.filter)
    self.navigationController?.toolbar.isHidden = false
    self.title = "Login"
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem
    rightBarButtonItem.target = self
    rightBarButtonItem.action = #selector(doneButton(_:))
    self.navigationItem.setHidesBackButton(true, animated: true)
    
    var toolbarItems = [UIBarButtonItem]()
    toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask(_:))))
    toolbarItems.append(UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(pushToSettings(_:))))
    self.toolbarItems = toolbarItems
    
    //enable block dragging
    self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
    collectionView.addGestureRecognizer(longPressGesture)
    self.view.layoutSubviews()
    print("\nOpening new graphing view with data: ")
    for task in activeTaskySet
    {
      task.soundOff()
    }
    

  }
  
  fileprivate func redrawCollection() {
    let activeTaskyCache = activeTaskySet
    let nullFilter = NSPredicate.init(value: false)
    activeTaskySet = TaskyNodeEditor.sharedInstance.database.filter(nullFilter)
    self.collectionView.reloadData()
    activeTaskySet = activeTaskyCache
    self.collectionView.reloadData()
  }
  override func viewWillAppear(_ animated: Bool)
  {
    
    collectionView.reloadData()
    if let nav = self.navigationController
    {
      nav.isToolbarHidden = false
    }
    redrawCollection()
  }
  
  // MARK: Custom Layout Method
  func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
  {
    //set cell height here
    return CGFloat(blockyHeight)
  }
  
  //MARK: Collection View
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return activeTaskySet.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "masterCollectionCell", for: indexPath) as! MasterGraphingCollectionViewCell
    for oldSubview in cell.subviews
    {
      oldSubview.removeFromSuperview()
    }
    switch indexPath.row == activeTaskySet.count
    {
    case false:
      let task = activeTaskySet[indexPath.row]
      cell.alpha = blockyAlpha
      cell.layer.borderColor = borderColor
      cell.autoresizesSubviews = true
      cell.layer.borderWidth = blockyBorder
      cell.layer.cornerRadius = blockyRadius
      cellTitleLabel = UILabel()
      cell.addSubview(cellTitleLabel)
      cellTitleLabel.frame = cell.bounds
      cellTitleLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      cellTitleLabel.textAlignment = .center
      cellTitleLabel.numberOfLines = 0
      cellTitleLabel.lineBreakMode = .byWordWrapping
      self.cellTitleLabel.text = task.title
      cell.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
    case true:
      cell.alpha = blockyAlpha
      cell.layer.borderColor = borderColor
      cell.autoresizesSubviews = true
      cell.layer.borderWidth = blockyBorder
      cell.layer.cornerRadius = blockyRadius
      cellTitleLabel = UILabel()
      cell.addSubview(cellTitleLabel)
      self.cellTitleLabel.text = "Add New"
      cell.backgroundColor = TaskyBlockLibrary.hexStringToUIColor(hex: colorString.purple.rawValue)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    print(indexPath)
    self.selectedTask = activeTaskySet[indexPath[1]]
    print(selectedTask.title)
    detailView(task: selectedTask)
    redrawCollection()
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
  @objc func addTask(_ sender: Any?)
  {
    let _ = TaskyNodeEditor.sharedInstance.newTask()
    redrawCollection()
  }
  
  //MARK: Drag items
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
  {
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
  
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
  {
    print("drag began at \(sourceIndexPath) and ended at \(destinationIndexPath)")
  }
  
  @objc func handleLongGesture(gesture: UILongPressGestureRecognizer)
  {
    switch(gesture.state)
    {
    case .began:
      guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else
      {
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
  
  //MARK: Actions
  
  @objc func doneButton(_ sender: UIBarButtonItem)
  {
    print("Done button pressed")
    if let unwrappedNextVCId = self.nextViewControllerId
    {
      let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let nextVC = storyBoard.instantiateViewController(withIdentifier: unwrappedNextVCId)
      navigationController?.pushViewController(nextVC, animated: true)
    }
    else if let unwrappedNextVC = nextViewController
    {
      navigationController?.pushViewController(unwrappedNextVC, animated: true)
    }
  }
  
  @objc func detailView(task: TaskyNode)
  {
    print("Detail View Selected")
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextVC = storyBoard.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
    nextVC.task = task
    nextVC.taskDetailDataSource = self
    navigationController?.pushViewController(nextVC, animated: true)
  }
  
  //Mark: Programmatic Navigation
  @objc func pushToSettings(_ sender: UIBarButtonItem)
  {
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let settingsViewController = storyBoard.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
    self.navigationController?.pushViewController(settingsViewController, animated: true)
  }
  
  //MARK: Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    switch segue.identifier
    {
    case "priorityToDetail":
      print("prepare for segue to detail with \(selectedTask.title) selected was called")
      let detailVC = segue.destination.childViewControllers.first as! DetailViewController
      detailVC.taskDetailDataSource = self
      detailVC.task = selectedTask
    default:
      return
    }
  }
  
  //Task Detail View Delegate
  func returnSelectedTask() -> TaskyNode
  {
    return selectedTask
  }
}
