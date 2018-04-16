import Foundation
import UIKit
//import _SwiftUIKitOverlayShims




  
class BaseCollectionViewFlowLayout : UICollectionViewLayout {
    
    
    var minimumLineSpacing: CGFloat = 2
    
     var minimumInteritemSpacing: CGFloat = 2
    
     var itemSize: CGSize =  CGSize.init(width: 10000, height: 10000)
  
     var estimatedItemSize: CGSize = CGSize.init(width: 200, height: 100)// defaults to CGSizeZero - setting a non-zero size enables cells that self-size via -preferredLayoutAttributesFittingAttributes:
    
     var scrollDirection: UICollectionViewScrollDirection = .vertical// default is UICollectionViewScrollDirectionVertical
    
     var headerReferenceSize: CGSize = CGSize.init(width: 0, height: 0)
    
     var footerReferenceSize: CGSize = CGSize.init(width: 0, height: 0)
    
     var sectionInset: UIEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    
    
    /// The reference boundary that the section insets will be defined as relative to. Defaults to `.fromContentInset`.
    /// NOTE: Content inset will always be respected at a minimum. For example, if the sectionInsetReference equals `.fromSafeArea`, but the adjusted content inset is greater that the combination of the safe area and section insets, then section content will be aligned with the content inset instead.



}

