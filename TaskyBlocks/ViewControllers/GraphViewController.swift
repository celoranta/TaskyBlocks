//
//  GraphViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-07.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift


class GraphViewController: UIViewController, SelectedTaskDestination, TaskSelectionSegueHandler {
  
  var selectedTask: Tasky!
  var snapshot: UIView?
  fileprivate var sourceIndexPath: IndexPath?
  fileprivate var sourceNode: TaskyNode?
  var dataModel: Results<Tasky>!
  var graphViewLayout: UICollectionViewLayout!
  //var visibleScreenSize: CGSize {return dynamicScreenSize}
  var collectionViewDelegate = GraphCollectionViewDelegate()
  var collectionViewDatasource = GraphCollectionViewDatasource()

  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var toolBarOutlet: UIToolbar!
  @IBOutlet weak var settingsBarItem: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let _ = try! Realm()
    dataModel = TaskyEditor.sharedInstance.taskDatabase
    
    if self.graphViewLayout == nil {
      self.hierarchyBarItem(self)
    }
    self.collectionView.delegate = collectionViewDelegate
    self.collectionView.dataSource = collectionViewDatasource
    collectionViewDelegate.delegate = self //does this belong here?
    self.toolBarOutlet.isTranslucent = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    refreshGraph()
  }
  
  fileprivate func refreshGraph() {
    GraphManager.sharedInstance.updateGraphs()
    self.collectionView.reloadData()
    self.graphViewLayout.invalidateLayout()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  
  func taskWasSelected() {
    let nodePaths = collectionView.indexPathsForSelectedItems
    if let nodePaths = nodePaths {
    let nodePath = nodePaths[0]
      //selectedTask = TaskyEditor.sharedInstance.taskDatabase[taskPath.row]
     guard let selectedNode = GraphManager.sharedInstance.node(for: nodePath)
      else {
        fatalError("No node at index path")
      }
      selectedTask = selectedNode.task
      pushToDetail(task: selectedTask)
      
      //print("Should navigate to detail view for task ",selectedTask," at path ", taskPath)
    }
  }
  
  //MARK: - Task Detail DataSource Methods
  
  func retrieveSelectedTask() -> Tasky {
    return selectedTask
  }
  
  @objc func pushToDetail(task: Tasky) {
    print("Detail View Selected")
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextVC = storyBoard.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
    nextVC.taskDetailSegueSource = self
    nextVC.task = selectedTask
    navigationController?.pushViewController(nextVC, animated: true)
  }
  
  @objc func pushToSettings(_ sender: UIBarButtonItem) {
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let settingsViewController = storyBoard.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
    self.navigationController?.pushViewController(settingsViewController, animated: true)
  }
  
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    switch segue.identifier {
//    case "priorityToDetail":
//      print("prepare for segue to detail with \(selectedTask.title) selected was called")
//      let detailVC = segue.destination.childViewControllers.first as! DetailViewController
//      detailVC.taskDetailSegueSource = self
//      detailVC.task = selectedTask
//    default:
//      return
//    }
//  }
  
  @IBAction func hierarchyBarItem(_ sender: Any) {
    print("Hierarchy Pressed")
    graphViewLayout = HierarchyGraphViewLayout()
  //  graphViewLayout.collectionViewLayoutDelegate = self
 //  collectionView.dataSource = self
    //let graphManager = GraphManager.sharedInstance //For testing only, does not belong here
    //graphManager.updateGraphs() //For testing only, does not belong here
    self.collectionView.setCollectionViewLayout(graphViewLayout, animated: true)
   refreshGraph()
  }
  
  @IBAction func dependenceBarItem(_ sender: Any) {
    print("Dependence Pressed")
//    graphViewLayout = DependenceGraphViewLayout()
//    graphViewLayout.collectionViewLayoutDelegate = self
//    collectionView.dataSource = self
//    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)
//    refreshGraph()
  }
  
  @IBAction func priorityBarItem(_ sender: Any) {
    print("Priority Pressed")
//   self.graphViewLayout = PriorityGraphViewLayout()
//    graphViewLayout.collectionViewLayoutDelegate = self
//    collectionView.dataSource = self
//    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)
//    refreshGraph()
  }
  
  @IBAction func SettingsBarItem(_ sender: Any) {
    print("Settings Pressed")
  }
  @IBAction func AddBarItem(_ sender: Any) {
    print("Add pressed")
    let _ = TaskyEditor.sharedInstance.newTask()
    self.collectionView.reloadData()
    self.collectionView.collectionViewLayout.invalidateLayout()
  }
  @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        print("Long Press")
    let location = sender.location(in: collectionView)

    //https://medium.com/@bhaveshtandel17/https-medium-com-bhaveshtandel17-how-to-create-custom-movable-uitableviewcell-uicollectionviewcell-8e90f3190606
    
      switch sender.state {
      case .began:
        print("Began")
        guard let currentIndexPath = collectionView.indexPathForItem(at: location)
          else {
            self.cleanup()
            return
        }
        guard let node = GraphManager.sharedInstance.node(for: currentIndexPath)
          else{
            self.cleanup()
            return
          }
        print("Source node: ", node.task)
        guard let cell = collectionView.cellForItem(at: currentIndexPath)
          else {
            self.cleanup()
            return
            }
          snapshot = self.customSnapshotFromView(inputView: cell)
          sourceIndexPath = collectionView.indexPathForItem(at: location)
          sourceNode = node
          guard let indexPath = sourceIndexPath
            else {
              self.cleanup()
              return
        }
          guard  let snapshot = self.snapshot else { return }
          var center = cell.center
          snapshot.center = center
          snapshot.alpha = 0.0
          self.collectionView.addSubview(snapshot)
          UIView.animate(withDuration: 0.25, animations: {
            center.y = location.y
            center.x = location.x
            snapshot.center = center
            snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            snapshot.alpha = 0.98
            cell.alpha = 0.0
          }, completion: { (finished) in
            cell.isHidden = false//This was set to TRUE in the original code
          })
          break
      case .changed:
        print("Changed")
        guard let defaultIndexPath = sourceIndexPath, let defaultNode = sourceNode, let snapshot = self.snapshot
          else {
            cleanup()
            return
        }
        let currentIndexPath = collectionView.indexPathForItem(at: location) ?? defaultIndexPath
        let currentNode = GraphManager.sharedInstance.node(for: currentIndexPath) ?? defaultNode
        var center = snapshot.center
        center.y = location.y
        center.x = location.x
        snapshot.center = center
       // let sourceIndexPath = self.sourceIndexPath
        let targetNode = currentNode //default is original position
//        if let targetIndex = collectionView.indexPathForItem(at: center) {
//        targetNode = GraphManager.sharedInstance.node(for: targetIndex)!
//        }
        print("New Target: ", targetNode.task.title )
        if let targetParent = targetNode.parent {
          print("Target Parent: ", targetParent.task.title)
          let siblings = targetParent.task.children
          guard let siblingIndex = siblings.index(of: targetNode.task)
            else {return}
          print("Sibling Index: ", siblingIndex)
          TaskyEditor.sharedInstance.removeAsChildToAllParents(task: defaultNode.task)
          TaskyEditor.sharedInstance.add(task: defaultNode.task, AsChildTo: targetParent.task, at: siblingIndex, and: false)
        }
        refreshGraph()
        //GraphManager.sharedInstance.updateGraphs()
       // collectionView.collectionViewLayout.invalidateLayout()
//        if indexPath != sourceIndexPath {
//          swap(&data[indexPath.row], &data[sourceIndexPath.row])
//          self.collectionView.moveItem(at: sourceIndexPath, to: indexPath)
//          self.sourceIndexPath = indexPath
//        }
      break
      case .ended:
        refreshGraph()
        //GraphManager.sharedInstance.updateGraphs()
        //collectionView.collectionViewLayout.invalidateLayout()
        //collectionView.layoutIfNeeded()
        self.cleanup()
        break
      default:
        guard let indexPath = sourceIndexPath
          else {return}
        guard let cell = self.collectionView.cellForItem(at: indexPath)
          else {
          return
        }
        guard  let snapshot = self.snapshot else {
          return
        }
        cell.isHidden = false
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
          snapshot.center = cell.center
          snapshot.transform = CGAffineTransform.identity
          snapshot.alpha = 0
          cell.alpha = 1
        }, completion: { (finished) in
          self.cleanup()
        })
    }
  }
  
  
  private func customSnapshotFromView(inputView: UIView) -> UIView? {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
    if let CurrentContext = UIGraphicsGetCurrentContext() {
      inputView.layer.render(in: CurrentContext)
    }
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
      UIGraphicsEndImageContext()
      return nil
    }
    UIGraphicsEndImageContext()
    let snapshot = UIImageView(image: image)
    snapshot.layer.masksToBounds = false
    snapshot.layer.cornerRadius = 0
    snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
    snapshot.layer.shadowRadius = 5
    snapshot.layer.shadowOpacity = 0.4
    return snapshot
  }
  
  private func cleanup() {
    self.sourceIndexPath = nil
    snapshot?.removeFromSuperview()
    self.snapshot = nil
  }
}
