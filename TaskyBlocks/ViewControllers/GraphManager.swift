//
//  GraphManager.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class GraphManager: NSObject {

  func node(for path: IndexPath) -> UICollectionViewCell /*Needs to return a node, not a cell*/ {
    return UICollectionViewCell()
  }
  
  //This should be unnecessary, as a NODE will be at an index path, and that contains a cell; so use node(for path: IndexPath) -> node
  func task(at path: IndexPath) -> Tasky {
   let placeholderTask = TaskyEditor.sharedInstance.newTask()
    return placeholderTask
  }
}
