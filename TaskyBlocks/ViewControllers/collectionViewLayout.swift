//
//  CollectionViewLayout.swift
//  PriorityViewTest
//
//  Created by Chris Eloranta on 2018-05-01.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

protocol CollectionViewLayoutDelegate {
  func datasource(for: CollectionViewLayout) -> [TaskyNode]
}

class CollectionViewLayout: UICollectionViewLayout {
  
  var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
  var contentSize: CGSize = CGSize.zero
  
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  var initialCellSize = CGSize(width: 100, height: 50)
  var initialCellSpacing = CGFloat.init(0)
  var cellPlotSize: CGSize
  {
   return CGSize.init(width: initialCellSize.width + initialCellSpacing, height: initialCellSize.height + initialCellSpacing)
  }
  
  var collectionViewLayoutDelegate: CollectionViewLayoutDelegate!
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var newAttributes: [UICollectionViewLayoutAttributes] = []
    for attribute in layoutMap
    {
      if attribute.value.frame.intersects(rect)
      {
        newAttributes.append(attribute.value)
      }
    }
    return newAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return layoutMap[indexPath]
  }
  

  private func center(rect1: CGSize, in rect2: CGRect) -> CGRect
  {
    let xOffset = 0.5 * (rect2.width - rect1.width)
    let yOffset = 0.5 * (rect2.height - rect1.height)
    let originX = rect2.origin.x + xOffset
    let originY = rect2.origin.y + yOffset
    let origin = CGPoint.init(x: originX, y: originY)
    return CGRect.init(origin: origin, size: rect1)
  }
 }


