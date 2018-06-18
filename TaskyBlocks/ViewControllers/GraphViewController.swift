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

  

  var selectedTask: Tasky! //This can't be a
  var dataModel: Results<Tasky>!

  var graphViewLayout: UICollectionViewLayout!
  //var visibleScreenSize: CGSize {return dynamicScreenSize}
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var toolBarOutlet: UIToolbar!
  @IBOutlet weak var settingsBarItem: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let _ = try! Realm()
    dataModel = TaskyEditor.sharedInstance.TaskDatabase
    
    if self.graphViewLayout == nil
    {
      self.hierarchyBarItem(self)
    }
  
    self.collectionView.delegate = GraphCollectionViewDelegate.init()
    self.collectionView.dataSource = GraphCollectionViewDatasource()
    self.toolBarOutlet.isTranslucent = true

  }
  
  override func viewWillAppear(_ animated: Bool) {
//    if let navigationController = self.navigationController
//    {
//    navigationController.setNavigationBarHidden(true, animated: true)
//    }
    //dynamicScreenSize = UIScreen.main.bounds.size
    refreshGraph()
  }
  
  fileprivate func refreshGraph()
  {
  
    self.collectionView.reloadData()
    self.graphViewLayout.invalidateLayout()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func taskWasSelected() {
    let tasksPath = collectionView.indexPathsForSelectedItems
    if let tasksPath = tasksPath {
    let taskPath = tasksPath[0]
    }
  }
  
  //MARK: - Task Detail DataSource Methods
  
  func retrieveSelectedTask() -> Tasky {
    return selectedTask //This should send an index path or get info from the node.
  }
  
  @objc func detailView(task: Tasky)
  {
    print("Detail View Selected")
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let nextVC = storyBoard.instantiateViewController(withIdentifier: "detailView") as! DetailViewController
    nextVC.task = task
    nextVC.taskDetailSegueSource = self
    navigationController?.pushViewController(nextVC, animated: true)
  }
  
  @objc func pushToSettings(_ sender: UIBarButtonItem)
  {
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let settingsViewController = storyBoard.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
    self.navigationController?.pushViewController(settingsViewController, animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "priorityToDetail":
      print("prepare for segue to detail with \(selectedTask.title) selected was called")
      let detailVC = segue.destination.childViewControllers.first as! DetailViewController
      detailVC.taskDetailSegueSource = self
      detailVC.task = selectedTask
    default:
      return
    }
  }
  
  @IBAction func hierarchyBarItem(_ sender: Any) {
    print("Hierarchy Pressed")
    graphViewLayout = HierarchyGraphViewLayout()
//    graphViewLayout.collectionViewLayoutDelegate = self
//    collectionView.dataSource = self
    let graphManager = GraphManager.init() //For testing only, does not belong here
    graphManager.createHierarchyGraph() //For testing only, does not belong here
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
//    self.graphViewLayout = PriorityGraphViewLayout()
//    graphViewLayout.collectionViewLayoutDelegate = self
//    collectionView.dataSource = self
//    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)
//    refreshGraph()
  }
  
  @IBAction func SettingsBarItem(_ sender: Any) {
    print("Settings Pressed")
  }
}
