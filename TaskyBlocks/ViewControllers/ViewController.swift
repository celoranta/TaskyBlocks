//
//  ViewController.swift
//  PriorityViewTest
//
//  Created by Chris Eloranta on 2018-05-01.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewLayoutDelegate {
  func datasource(for: CollectionViewLayout) -> [TaskyNode] {
    return self.dataSource
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "taskCell", for: indexPath) as! TaskCollectionViewCell
    let task = dataSource[indexPath.row]
    cell.setupCellWith(task: task)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  
  
  var dataSource: [TaskyNode]!
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.collectionViewLayout = PriorityCollectionViewLayout()
    let layout = collectionView.collectionViewLayout as! CollectionViewLayout
    layout.collectionViewLayoutDelegate = self
    dataSource = []
    let taskQty = 15
    for _ in 0..<taskQty
    {
      let task = TaskyNode()
      dataSource.append(task)
      print("\(task.priority)")
    }
    
    let task = dataSource[4]
    task.dependees = [dataSource[5], dataSource[6]]
    
    let task2 = dataSource[5]
    task2.dependees = [dataSource[7]]
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @objc func priorityView()
  {
   print("priority")
    self.collectionView.collectionViewLayout = PriorityCollectionViewLayout()
    self.collectionView.collectionViewLayout.invalidateLayout()
  }
  
  @objc func dependenceView()
  {
    print("dependency")
    self.collectionView.collectionViewLayout = DependenceCollectionViewLayout()
    self.collectionView.collectionViewLayout.invalidateLayout()
  }


}

