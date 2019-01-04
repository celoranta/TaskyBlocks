//
//  GraphCollectionViewDelegate.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol TaskSelectionSegueHandler {
  func taskWasSelected()
}



class GraphCollectionViewDelegate: NSObject, UICollectionViewDelegate, UIGestureRecognizerDelegate {
  
  var delegate: TaskSelectionSegueHandler!
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print(indexPath)
    
    delegate.taskWasSelected()
  }
  

  
  // Support for reordering

}
