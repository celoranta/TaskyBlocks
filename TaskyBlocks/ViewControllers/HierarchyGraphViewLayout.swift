

import UIKit

class HierarchyGraphViewLayout: GraphCollectionViewLayout {
  var layoutMap = [IndexPath: UICollectionViewLayoutAttributes]()
  var contentSize: CGSize = CGSize.zero
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var newAttributes: [UICollectionViewLayoutAttributes] = []
    for attribute in layoutMap {
      if attribute.value.frame.intersects(rect) {
        newAttributes.append(attribute.value)
      }
    }
    return newAttributes
  }
  
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      return layoutMap[indexPath]
    }
  
  override func prepare() {
    
    //What follows is just to get something back on the screen.
    contentSize = CGSize.init(width: 1000.0, height: 1000.0)
    let inappropriateGraphManager = GraphManager()
    inappropriateGraphManager.createHierarchyGraph()
    let hierarchyLayoutData = inappropriateGraphManager.treePaths
    for i in hierarchyLayoutData {
      let layoutAttribute = UICollectionViewLayoutAttributes.init(forCellWith: i.key)
      layoutAttribute.size = self.initialCellSize
      let row = CGFloat(i.value.count)
      let iOrigin = CGPoint.init(x: layoutAttribute.size.width * CGFloat(i.key.row), y: layoutAttribute.size.height * row)
      layoutAttribute.frame = CGRect.init(origin: iOrigin, size: layoutAttribute.size)
      layoutMap.updateValue(layoutAttribute, forKey: i.key)
    }
    //Will need to ask the graph manager for the size (if not the position) for each index path
  }
}

//  var preGenerationMap: [HierarchyGraphingNode] = []
//  //var generationMap = [CGFloat : [HierarchyGraphingNode]]()
//  var generationMap = [[HierarchyGraphingNode]]()
//  var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
//  var contentSize: CGSize = CGSize.init(width: 1000, height: 1000)
//  var maxGenerations: CGFloat = 0
//  override var collectionViewContentSize: CGSize {
//    return contentSize
//  }
//
//  var initialCellSpacing = CGFloat.init(0)
//  var cellPlotSize: CGSize {
//    return CGSize.init(width: initialCellSize.width + initialCellSpacing, height: initialCellSize.height + initialCellSpacing)
//  }
//
//  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//    var newAttributes: [UICollectionViewLayoutAttributes] = []
//    for attribute in layoutMap {
//      if attribute.value.frame.intersects(rect) {
//        newAttributes.append(attribute.value)
//      }
//    }
//    return newAttributes
//  }
//
//  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//    return layoutMap[indexPath]
//  }
//
//  private func center(rect1: CGSize, in rect2: CGRect) -> CGRect {
//    let xOffset = 0.5 * (rect2.width - rect1.width)
//    let yOffset = 0.5 * (rect2.height - rect1.height)
//    let originX = rect2.origin.x + xOffset
//    let originY = rect2.origin.y + yOffset
//    let origin = CGPoint.init(x: originX, y: originY)
//    return CGRect.init(origin: origin, size: rect1)
//  }
//
//  override func prepare() {
//    super.prepare()
//
//  }
//
//  fileprivate func countChildlessDescendants(of task: Tasky) -> CGFloat {
//    var childCount: CGFloat = 0.0
//    for child in task.children
//    {
//      if child.children.count == 0 {
//        childCount += CGFloat(1.0)
//      }
//      else {
//        childCount += countChildlessDescendants(of: child)
//      }
//    }
//    return childCount
//  }
//
//  fileprivate func hierarchyGraphingNode(for task: Tasky, parent: Tasky?) -> HierarchyGraphingNode? {
//    if let parent = parent {
//      for generation in generationMap {
//        for node in generation {
//          if node.task.parents.contains(parent) && node.task == task {
//            return node
//          }
//        }
//      }
//    }
//    else if generationMap[0].filter({$0.task == task}).count > 0 {
//      for node in generationMap[0] {
//        if node.task == task {
//          return node
//        }
//      }
//    }
//    return nil
//  }
//
//  fileprivate func sumOfPriorSiblingWidths(node: HierarchyGraphingNode) -> CGFloat {
//    var count: CGFloat = 0
//    if node.parents.count == 0 {
//      return 0
//    }
//    else {
//      for child in node.parents[0].children
//      {
//        if child.siblingPaths[0].siblingIndex! < node.siblingPaths[0].siblingIndex! {
//          count += (child.siblingPaths[0].siblingIndex!)
//        }
//      }
//    }
//    return count
//  }
//
//  fileprivate func xOffset(per siblingPath: SiblingPath) -> CGFloat {
//    var offset: CGFloat = 0.0
//    if let parent = siblingPath.parent {
//      for child in parent.children {
//        for childSiblingPath in child.siblingPaths {
//          if childSiblingPath.siblingIndex! < siblingPath.siblingIndex! {
//            offset += child.width
//          }
//        }
//      }
//      offset += parent.width
//    }
//    return offset
//  }
//
//  fileprivate func createGeneration(following generation: [HierarchyGraphingNode]) -> [HierarchyGraphingNode] {
//    var newGeneration: [HierarchyGraphingNode] = []
//    for node in generation {
//      for child in node.task.children {
//        newGeneration.append(HierarchyGraphingNode.init(task: child, parent: node))
//      }
//    }
//    return newGeneration
//  }
//}
