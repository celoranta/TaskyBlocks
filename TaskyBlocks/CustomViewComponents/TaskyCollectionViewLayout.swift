////
////  TaskyCollectionViewLayout.swift
////  TaskyBlocks
////
////  Created by Chris Eloranta on 2018-04-13.
////  Copyright © 2018 Christopher Eloranta. All rights reserved.
////
//
//import UIKit
//
//class TaskyCollectionViewLayout: UICollectionViewLayout
//{
//  let TaskyViewAutomaticAlpha: CGFloat = 1
//  let TaskyViewAutomaticBounds = CGSize.init(width: 10000, height: 10000)
//let TaskyViewAutomaticSize: CGSize = CGSize.init(width: 200, height: 100)
//  
//  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
//  {
//    let attributes = [UICollectionViewLayoutAttributes()]
//    return attributes
//  }
//  
//  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//    return nil
//  }
//  
//  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//    return false
//  }
//  
// func defaultLayoutAttributes()
// {
//  var attributes = UICollectionViewLayoutAttributes()
//  attributes.alpha = TaskyViewAutomaticAlpha
//  attributes.bounds.equalTo(TaskyViewAutomaticBoundsSize)
//  attributes.center
//  }
//  
//}
//
//
//
////open class UICollectionViewLayoutAttributes : NSObject, NSCopying, UIDynamicItem {
////
////
////  open var frame: CGRect
////
////  open var center: CGPoint
////
////  open var size: CGSize
////
////  open var transform3D: CATransform3D
////
////  @available(iOS 7.0, *)
////  open var bounds: CGRect
////
////  @available(iOS 7.0, *)
////  open var transform: CGAffineTransform
////
////  open var alpha: CGFloat
////
////  open var zIndex: Int // default is 0
////
////  open var isHidden: Bool // As an optimization, UICollectionView might not create a view for items whose hidden attribute is YES
////
////  open var indexPath: IndexPath
////
////
////  open var representedElementCategory: UICollectionElementCategory { get }
////
////  open var representedElementKind: String? { get } // nil when representedElementCategory is UICollectionElementCategoryCell
////
////
////  public convenience init(forCellWith indexPath: IndexPath)
////
////  public convenience init(forSupplementaryViewOfKind elementKind: String, with indexPath: IndexPath)
////
////  public convenience init(forDecorationViewOfKind decorationViewKind: String, with indexPath: IndexPath)
////}
