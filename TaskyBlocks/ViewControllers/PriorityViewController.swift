//
//  PriorityViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-13.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class PriorityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TaskDetailDataSource {
  
  
  //var realm: Realm!
  var activeTaskySet: Results<TaskyNode>!
  let filter = "completionDate == nil"
  let blockyAlpha: CGFloat = 0.75
  var blockyWidth: CGFloat = 123.5
  let layout = UICollectionViewFlowLayout()
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
      return CGSize.init(width: blockyWidth, height: blockyHeight)
    }
  }
  var selectedTask: TaskyNode!

  @IBOutlet weak var priorityCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    layout.itemSize = blockSize
    //layout.estimatedItemSize = CGSize.init(width: 500, height: 500)
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2
    //layout.sectionInset = .init(top: blockyHeight, left: blockyHeight, bottom: blockyWidth, right: blockyWidth)
    priorityCollectionView.collectionViewLayout = layout
    activeTaskySet = TaskyNodeEditor.sharedInstance.database.filter(self.filter)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    priorityCollectionView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return activeTaskySet.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
    let task = activeTaskySet[indexPath.row]
    let taskyLabel = UILabel.init(frame: cell.bounds)
    let taskyBlock = UIView()
    
    cell.addSubview(taskyBlock)
    taskyBlock.addSubview(taskyLabel)
    
    cell.frame.size = blockSize
    cell.alpha = blockyAlpha
    cell.backgroundColor = UIColor.clear
    cell.autoresizesSubviews = true
    
    taskyBlock.frame = cell.bounds
    taskyBlock.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    taskyBlock.layer.borderWidth = blockyBorder
    taskyBlock.layer.cornerRadius = blockyRadius
    taskyBlock.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
    taskyBlock.autoresizesSubviews = true
    
    taskyLabel.frame = taskyBlock.bounds
    taskyLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    taskyLabel.text = "\(task.title)"//"\(task.priorityApparent)"
    taskyLabel.textAlignment = .center
    taskyLabel.numberOfLines = 0
    taskyLabel.lineBreakMode = .byWordWrapping
    taskyLabel.font.withSize(blockyWidth / 12)
  
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
  {
    print(indexPath)
    self.selectedTask = activeTaskySet[indexPath[1]]
    print(selectedTask.title)
    
    //TaskyNodeEditor.sharedInstance.complete(task: selectedTask)
    performSegue(withIdentifier: "priorityToDetail", sender: self)
    self.priorityCollectionView.reloadData()
  }
  
  @IBAction func addButton(_ sender: Any)
  {
    _ = TaskyNodeEditor.sharedInstance.newTask()
    self.priorityCollectionView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier
    {
    case "priorityToDetail":
      print("prepare for segue to detail with \(selectedTask.title) selected was called")
      let detailVC = segue.destination.childViewControllers.first as! DetailViewController
      detailVC.taskDetailDataSource = self as! TaskDetailDataSource
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
