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
  fileprivate var sourceTreePath: TreePath?
  
  //fileprivate var sourceParent: TaskyNode!
  fileprivate var sourceParentIndexPath: IndexPath?
  fileprivate var sourceParent: TaskyNode!
  //fileprivate var sourceParentNodes: [TaskyNode] = []
  
  fileprivate var currentNode: TaskyNode?
  fileprivate var currentParent: TaskyNode?
  fileprivate var siblingIndex: Int?

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
       sourceIndexPath = collectionView.indexPathForItem(at: location)
        guard let node = GraphManager.sharedInstance.node(for: sourceIndexPath!)
          else{
            self.cleanup()
            return
          }
        print("Source node: ", node.task)
        
        sourceParent = node.parent
        guard let sourceParentU = node.parent
          else {
            self.cleanup()
            return
        }
        sourceParent = sourceParentU
        let x = GraphManager.sharedInstance.nodes.keysForValue(value: sourceParent).count
        if x == 0 {
          self.cleanup()
          return
        }
        sourceParentIndexPath = GraphManager.sharedInstance.nodes.keysForValue(value: sourceParent)[0]
        
        
        sourceTreePath = node.treePath
         guard let cell = collectionView.cellForItem(at: sourceIndexPath!)
          else {
            self.cleanup()
            return
            }
          snapshot = self.customSnapshotFromView(inputView: cell)
          sourceNode = node
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
            //cell.alpha = 0.00
          }, completion: { (finished) in
            cell.isHidden = false//This was set to TRUE in the original code
            cell.alpha = 0.25//This was added by me
          })
          break
        
      case .changed:
        print("Changed")
        guard let defaultIndexPath = sourceIndexPath, let defaultNode = sourceNode, let defaultParentIndexPath = sourceParentIndexPath, let snapshot = self.snapshot
          else {
            cleanup()
            return
        }
        let collectionViewLayout = collectionView.collectionViewLayout as! GraphCollectionViewLayout
        let cellHeight = collectionViewLayout.initialCellHeight
        let parentLocation = CGPoint(x: location.x,y:  location.y - cellHeight)
        let currentIndexPath = collectionView.indexPathForItem(at: location) ?? defaultIndexPath
        let currentNode = GraphManager.sharedInstance.node(for: currentIndexPath) ?? defaultNode
        let parentIndexPath = collectionView.indexPathForItem(at: parentLocation) ?? defaultParentIndexPath
        currentParent = GraphManager.sharedInstance.node(for: parentIndexPath)

        var center = snapshot.center
        center.y = location.y
        center.x = location.x
        snapshot.center = center
        
        //Could this be done with nodes sans tasks?
        var siblings: List<Tasky>
        
        if let currentParent = currentParent {
        siblings = currentParent.task.children
        siblingIndex = siblings.index(of: currentNode.task) ?? 0
          if let siblingIndex = siblingIndex {
          print("Sibling Index: ", siblingIndex)
          }
          //If these could be calculated using nodes
          TaskyEditor.sharedInstance.removeAsChildToAllParents(task: defaultNode.task)

//            if !sourceParentNodes.contains(defaultNode){
//              TaskyEditor.sharedInstance.remove(task: defaultNode.task, asChildTo: parent)
//            }

          TaskyEditor.sharedInstance.add(task: defaultNode.task, AsChildTo: currentParent.task, at: siblingIndex, and: false)
        }
        
        if let _ = collectionView.indexPathForItem(at: parentLocation){
          snapshot.isHidden = true
        }
        else {
          snapshot.isHidden = false
        }
        refreshGraph()
      break
        
//      case .ended:
//        if let currentParent = currentParent {
//
//        refreshGraph()
//        self.cleanup()
//        break
        
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
    self.sourceTreePath = nil
    snapshot?.removeFromSuperview()
    self.snapshot = nil
  }
}
