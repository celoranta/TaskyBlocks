//
//  GraphCollectionViewLayout.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-10.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol CollectionViewLayoutDelegate {
  var initialCellSize: CGSize {get}
  func datasource() -> [TaskyNode]
}

class GraphCollectionViewLayout: UICollectionViewLayout {

  var collectionViewLayoutDelegate: CollectionViewLayoutDelegate!
  var initialCellSize: CGSize!
  override func prepare() {
    
    initialCellSize = self.collectionViewLayoutDelegate.initialCellSize
  }
}
