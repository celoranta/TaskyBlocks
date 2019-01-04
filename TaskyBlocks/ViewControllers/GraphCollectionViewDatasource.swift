//
//  GraphCollectionViewDatasource.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class GraphCollectionViewDatasource: NSObject, UICollectionViewDataSource {
  
  //var graphManager = GraphManager()

  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    if section == 0 {
      return GraphManager.sharedInstance.nodes.count
    }
    else{
    let count = TaskyEditor.sharedInstance.countActiveTasks()
    return count
  }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphingCell", for: indexPath) as! GraphingCollectionViewCell
    //let task = TaskyEditor.sharedInstance.taskDatabase[indexPath.row]
    guard let node = GraphManager.sharedInstance.node(for: indexPath)
      else {
        fatalError("Node not found")
    }
    let task = node.task
     cell.setupCellWith(task: task)
    return cell
//
//    else{
//    fatalError("No task returned with node")
//    }
  }
  
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func cellData(for indexPath: IndexPath) {
    
  }

}
