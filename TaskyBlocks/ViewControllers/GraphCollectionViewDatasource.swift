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
    let count = TaskyEditor.sharedInstance.countActiveTasks()
    return count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphingCell", for: indexPath) as! GraphingCollectionViewCell
    let task = TaskyEditor.sharedInstance.taskDatabase[indexPath.row]
     cell.setupCellWith(task: task)
    return cell
//
//    else{
//    fatalError("No task returned with node")
//    }
  }
  
  func cellData(for indexPath: IndexPath) {
    
  }

}
