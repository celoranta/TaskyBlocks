

import UIKit



class HierarchyGraphViewLayout: GraphCollectionViewLayout, GraphViewLayout {
  var collectionViewLayoutDelegate: CollectionViewLayoutDelegate!

  var column = 0
  var localDatasource = Array(TaskyNodeEditor.sharedInstance.database)
  var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
  var contentSize: CGSize = CGSize.init(width: 1000, height: 1000)
  
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  var initialCellSize = CGSize(width: 100, height: 100)
  var initialCellSpacing = CGFloat.init(0)
  var cellPlotSize: CGSize
  {
    return CGSize.init(width: initialCellSize.width + initialCellSpacing, height: initialCellSize.height + initialCellSpacing)
  }
  
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
  
  override func prepare() {
      contentSize = CGSize.init(width: 1500, height: 1500)
    layoutMap = [:]
    for task in localDatasource
    {
      if let indexInDataSource = localDatasource.index(of: task)
      {
      let indexPath = IndexPath.init(row: indexInDataSource, section: 0)
        let attribute = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        attribute.frame.size = self.cellPlotSize
        attribute.frame.origin = CGPoint.init(x: 0, y: cellPlotSize.height * CGFloat(indexPath.row))
        layoutMap[indexPath] = attribute
      }
      
    }

  }
  

  
}