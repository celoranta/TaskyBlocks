//
//  GraphCollectionViewDatasource.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

var graphManager = GraphManager()

class GraphCollectionViewDatasource: NSObject, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphingCell", for: indexPath) as! GraphingCollectionViewCell
    if let node = graphManager.node(for: indexPath) {
      if let task = node.task {
      cell.setupCellWith(task: task)
    return cell
      }
    }
    fatalError("No task returned with node")
  }
  
  func cellData(for indexPath: IndexPath) {
    
  }

}
