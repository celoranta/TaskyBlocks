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
  
  
}
