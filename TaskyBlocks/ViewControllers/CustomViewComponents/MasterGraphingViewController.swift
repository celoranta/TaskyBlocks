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
  var activeResults: Results<TaskyNode>!
  var currentDataModel: [TaskyNode]!
  var selectedTask: TaskyNode!
  var nextViewController: UIViewController? = nil
  var nextViewControllerId: String?
  var includesAddBlock: Bool = false
  
  //MARK: Database
  var realm: Realm!
  var notificationToken: NotificationToken!
  var masterGraphingViewController: MasterGraphingViewController? = nil
  
  fileprivate var longPressGesture: UILongPressGestureRecognizer!
  
  //MARK: CollectionView Cell parameters
  let newPlusImage = UIImage.init(named: "greyPlus")
  let highlightBorderColor = UIColor.yellow.cgColor
  var cellTitleLabel: UILabel!
  let borderColor = UIColor.darkGray.cgColor
  var blockyWidth: CGFloat = 123.5
  let blockyAlpha: CGFloat = 0.75
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
  
  
  //MARK: Nav Controller and Tool Bar Properties
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
    
    try! realm = Realm()
    
    
    collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: customLayout)
    self.view.addSubview(collectionView)
    collectionView.register(MasterGraphingCollectionViewCell.self, forCellWithReuseIdentifier: "masterCollectionCell")
    collectionView.backgroundColor = UIColor.white
    customLayout.delegate = self
    collectionView.delegate = self
    collectionView.dataSource = self
    activeResults = TaskyNodeEditor.sharedInstance.database.filter(self.filter)
    currentDataModel = Array(activeResults)
    currentDataModel.sort(by: { $0.priorityApparent < $1.priorityApparent})
    self.subscribeToNotifications()
    self.navigationController?.toolbar.isHidden = false
    self.title = "Login"
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem
    rightBarButtonItem.target = self
    rightBarButtonItem.action = #selector(doneButton(_:))
    self.navigationItem.setHidesBackButton(true, animated: true)
    
    var toolbarItems = [UIBarButtonItem]()
    let leftSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let rightSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let settings = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(pushToSettings(_:)))
    toolbarItems.append(contentsOf: [leftSpacer, settings, rightSpacer])
    self.toolbarItems = toolbarItems
    
    //enable block dragging
    self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
    self.longPressGesture.minimumPressDuration = 0.12
    collectionView.addGestureRecognizer(longPressGesture)
    self.view.layoutSubviews()
    print("\nOpening new graphing view with data: ")
    for task in currentDataModel
    {
      task.soundOff()
    }
  }
  
  fileprivate func redrawCollection() {
    currentDataModel = []
    self.collectionView.reloadData()
    currentDataModel = Array(activeResults)
    currentDataModel.sort(by: { $0.priorityApparent > $1.priorityApparent})
    self.collectionView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool)
  {
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
    return currentDataModel.count + self.includesAddBlock.hashValue
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "masterCollectionCell", for: indexPath) as! MasterGraphingCollectionViewCell
    for oldSubview in cell.subviews
    {
      oldSubview.removeFromSuperview()
    }
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
    switch indexPath.row == currentDataModel.count
    {
    case false:
      let task = currentDataModel[indexPath.row]
      self.cellTitleLabel.text = task.title
      cell.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
      
    case true:
      self.cellTitleLabel.text = "<add new>"
      self.cellTitleLabel.textColor = UIColor.gray
      cell.backgroundColor = TaskyBlockLibrary.hexStringToUIColor(hex: colorString.purple.rawValue)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    print(indexPath)
    let addButtonIndex = self.currentDataModel.count
    switch indexPath.row >= addButtonIndex
    {
    case false:
      self.selectedTask = currentDataModel[indexPath[1]]
      print(selectedTask.title)
      detailView(task: selectedTask)
    case true:
      self.addTask(nil)
    }
    redrawCollection()
  }
  
  @objc func addTask(_ sender: Any?)
  {
    let _ = TaskyNodeEditor.sharedInstance.newTask()
    redrawCollection()
  }
  
  //MARK: Drag items
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
  {
    let task = currentDataModel[indexPath.row]
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
    //currentDataModel.insert(currentDataModel.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
    let task1 = currentDataModel[destinationIndexPath.row]
    let task2 = currentDataModel[destinationIndexPath.row - 1]
    let meanAverage = (task1.priorityApparent + task2.priorityApparent) * 0.5
    let editedTask = currentDataModel[sourceIndexPath.row]
    TaskyNodeEditor.sharedInstance.updatePriorityDirect(of: editedTask, to: meanAverage)
    
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
      collectionView.endInteractiveMovement()
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
  
  //MARK: Realm Notifications
  func subscribeToNotifications()
  {
    masterGraphingViewController = self
    notificationToken = activeResults.observe { [weak self] (changes: RealmCollectionChange) in
      guard let masterGraphingViewController = self?.masterGraphingViewController else
      {
        print("guard statement did not allow further processing")
        return
      }
      switch changes
      {
      case .initial:
        print("Initial")
        masterGraphingViewController.processRealmNotificationReceipt()
      case . update:
        print("Update")
        masterGraphingViewController.processRealmNotificationReceipt()
      case .error(let error):
        print(error)
      }
    }
  }
  
  func processRealmNotificationReceipt()
  {
  print("Realm notification received!")
 // notificationToken.invalidate()
    redrawCollection()
   // subscribeToNotifications()
  }
}
