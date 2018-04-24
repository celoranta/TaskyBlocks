//
//  FinalPriorityCollectionViewLayout.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-17.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class FinalPriorityCollectionViewLayout: MasterGraphingCollectionViewLayout {
  
  var cellPadding: CGFloat = 2
  var cellWidth: CGFloat = 150.0
  var cachedWidth: CGFloat = 0.0
  
  fileprivate var numberOfItems = 0
  fileprivate var cache = [UICollectionViewLayoutAttributes]()
  fileprivate var contentHeight: CGFloat  = 0.0
  
  fileprivate var contentWidth: CGFloat {
    if let collectionView = collectionView {
      let insets = collectionView.contentInset
      return collectionView.bounds.width - (insets.left + insets.right)
    }
    return 0
  }
  
  override public var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth /* * zoomFactor*/, height: contentHeight /** zoomFactor*/) // Here's where the height gets adjusted, but this is calculated from the graphing size
  }
  
  override public func prepare() {
    print("Preparing layout attributes")
    cellWidth = contentWidth * 0.85
    guard let collectionView = collectionView else { return }
    let numberOfColumns = 1
    let totalSpaceWidth = contentWidth - CGFloat(numberOfColumns) * cellWidth
    let horizontalPadding = totalSpaceWidth / CGFloat(numberOfColumns + 1)
    let numberOfItems = collectionView.numberOfItems(inSection: 0)
    
    if (contentWidth != cachedWidth || self.numberOfItems != numberOfItems) {
      cache = []
      contentHeight = 0
      self.numberOfItems = numberOfItems
    }
    
    if cache.isEmpty {
      print("Layout attribute cache is empty.  Preparing new cache")
      cachedWidth = contentWidth
      var xOffset = [CGFloat]()
      for column in 0 ..< numberOfColumns {
        xOffset.append(CGFloat(column) * cellWidth + CGFloat(column + 1) * horizontalPadding)
      }
      var column = 0
      var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
      
      for row in 0 ..< numberOfItems {
        
        let indexPath = IndexPath(row: row, section: 0)
        
        let cellHeight = delegate.collectionView(collectionView: collectionView, heightForCellAtIndexPath: indexPath, width: cellWidth)
        let height = cellPadding +  cellHeight + cellPadding
        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: height)
        let insetFrame = frame.insetBy(dx: 0, dy: cellPadding)
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
        attributes.frame = insetFrame
        cache.append(attributes)
        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + height
        
        if column >= (numberOfColumns - 1) {
          column = 0
        } else {
          column = column + 1
        }
      }
    }
  }
  
  override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    print("Calculating layout attributes for rect")
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    for attributes in cache { // #7
      if attributes.frame.intersects(rect) { // #8
        layoutAttributes.append(attributes) // #9
      }
    }
    return layoutAttributes
  }
}
