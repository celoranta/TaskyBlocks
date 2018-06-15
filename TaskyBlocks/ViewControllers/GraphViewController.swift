//
//  GraphViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-07.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

protocol GraphViewLayout {
  var collectionViewLayoutDelegate: CollectionViewLayoutDelegate! {get set}
}

class GraphViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewLayoutDelegate, TaskDetailDataSource {
  

  var selectedTask: TaskyNode!
  var initialCellWidth: CGFloat!
  var initialCellHeight: CGFloat!
  var dataSource: Results<TaskyNode>!
  var graphViewLayout: GraphViewLayout!
  var visibleScreenSize: CGSize {return dynamicScreenSize}
  var dynamicScreenSize: CGSize = CGSize.zero
  var initialCellSize: CGSize {
    return CGSize.init(width: initialCellWidth, height: initialCellHeight)
  }
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var toolBarOutlet: UIToolbar!
  @IBOutlet weak var settingsBarItem: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let _ = try! Realm()

    dataSource = TaskyNodeEditor.sharedInstance.database
    if self.graphViewLayout == nil
    {
      self.priorityBarItem(self)
    }
    self.graphViewLayout.collectionViewLayoutDelegate = self

    self.toolBarOutlet.isTranslucent = true
    
    self.initialCellWidth = 110
    self.initialCellHeight = 0.5 * initialCellWidth
    
    selectedTask = dataSource.last!
  }
  
  override func viewWillAppear(_ animated: Bool) {
//    if let navigationController = self.navigationController
//    {
//    navigationController.setNavigationBarHidden(true, animated: true)
//    }
    dynamicScreenSize = UIScreen.main.bounds.size
    refreshGraph()
  }
  
  fileprivate func refreshGraph()
  {
    let layout = self.graphViewLayout as! UICollectionViewLayout // ToDo this is a lie use polymorphism. ie subclasses of uicollectionview layout
    self.collectionView.reloadData()
    layout.invalidateLayout()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return dataSource.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphingCell", for: indexPath) as! GraphingCollectionViewCell
    let task = dataSource[indexPath.row]
    cell.setupCellWith(task: task)
    
    return cell
  }
  
  //MARK: - Task Detail DataSource Methods
  

  func returnSelectedTask() -> TaskyNode {
    return selectedTask
  }
  
  func datasource() -> [TaskyNode] {
    return Array(dataSource)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(indexPath)
    self.selectedTask = Array(self.dataSource)[indexPath[1]]
    print(selectedTask.title)
    detailView(task: selectedTask)
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
      detailVC.taskDetailDataSource = self
      detailVC.task = selectedTask

    default:
      return
    }
  }
  
  @IBAction func hierarchyBarItem(_ sender: Any) {
    print("Hierarchy Pressed")
    graphViewLayout = HierarchyGraphViewLayout()
    graphViewLayout.collectionViewLayoutDelegate = self
    collectionView.dataSource = self
    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)
    refreshGraph()
  }
  
  @IBAction func dependenceBarItem(_ sender: Any) {
    print("Dependence Pressed")
    graphViewLayout = DependenceGraphViewLayout()
    graphViewLayout.collectionViewLayoutDelegate = self
    collectionView.dataSource = self
    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)
    refreshGraph()
  }
  
  @IBAction func priorityBarItem(_ sender: Any) {
    print("Priority Pressed")
    self.graphViewLayout = PriorityGraphViewLayout()
    graphViewLayout.collectionViewLayoutDelegate = self
    collectionView.dataSource = self
    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)
    refreshGraph()
  }
  
  @IBAction func SettingsBarItem(_ sender: Any) {
    print("Settings Pressed")
    
  }
  

  
  
}
