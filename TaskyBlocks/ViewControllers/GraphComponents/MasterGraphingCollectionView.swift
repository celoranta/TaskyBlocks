//
//  MasterGraphingCollectionView.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-16.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class MasterGraphingCollectionView: UICollectionView, LiquidLayoutDelegate {
  

  func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
   return CGFloat.init(10 % indexPath.row)
  }
  

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
