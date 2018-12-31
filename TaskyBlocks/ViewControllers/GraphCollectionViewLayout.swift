//
//  GraphCollectionViewLayout.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-10.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit


class GraphCollectionViewLayout: UICollectionViewLayout {

  var initialCellWidth: CGFloat = 110
  var initialCellHeight: CGFloat {
    return 0.5 * initialCellWidth
  }
  var initialCellSize: CGSize {
    return CGSize.init(width: initialCellWidth, height: initialCellHeight)
  }
  
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  
  var contentSize: CGSize {
    return CGSize.init(width: graphSize.width + centeringMargin, height: graphSize.height)
  }
  var graphSize: CGSize {
    return CGSize.init(width: graphWidth, height: graphHeight)
  }
  var graphWidth: CGFloat = 0.0
  var graphHeight: CGFloat = 0.0
  var centeringMargin: CGFloat {
  let screenWidth = UIScreen.main.bounds.width
    let screenMargin = (screenWidth - graphWidth) / 2
    return screenMargin > 0 ? screenMargin : 0.0
  }
  
  
  
}
