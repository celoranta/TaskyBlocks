

import UIKit

class HierarchyGraphViewLayout: GraphCollectionViewLayout {
  var layoutMap = [IndexPath: UICollectionViewLayoutAttributes]()
  /*I think the layoutMap should just be [IndexPath: TaskyNode], and all other data points
   such as UICollectionViewLayoutAttributes, treePath, and temporary registers for x, y, row, etc...
   should all be properties of TaskyNode.
 */
 var contentSize: CGSize = CGSize.zero
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  let inappropriateGraphManager = GraphManager()
  
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
    //The graphmanager will probably end up being a singleton.
    inappropriateGraphManager.createHierarchyGraph()
    //Create a layout attribute for each graph data point
    for graphDataPoint in inappropriateGraphManager.nodes {
      let layoutAttribute = UICollectionViewLayoutAttributes.init(forCellWith: graphDataPoint.key)
      let node = graphDataPoint.value
      node.layoutAttribute = layoutAttribute
      //layoutMap.updateValue(layoutAttribute, forKey: graphDataPoint.key)
    }
    
    //Calculate a size for the layoutAttribute associated with each graphDataPoint
    for graphDataPoint in inappropriateGraphManager.nodes.sorted(by: {$0.value.treePath.count > $1.value.treePath.count}) {
      let indexPath = graphDataPoint.key
      let node = graphDataPoint.value
      if let layoutAttribute = node.layoutAttribute{
        layoutAttribute.size = calculateBlockSize(for: indexPath)
      }
      else {
        fatalError("layoutAttribute or treepath not found")
      }
      
      let row = calculateRow(for: node.treePath)
      node.y = calculateY(for: node.layoutAttribute, and: row)
        }
    
    
    
    for graphDataSet in inappropriateGraphManager.nodes {
      let node = graphDataSet.value
      let indexPath = graphDataSet.key

      let treePath = node.treePath
      let row = calculateRow(for: treePath)
      guard let layoutAttribute = node.layoutAttribute
        else {
          fatalError("Node has no layoutAttribue value")
      }
      let y = calculateY(for: layoutAttribute, and: row)
      let x = calculateX(for: layoutAttribute)
      layoutAttribute.frame = CGRect.init(origin: CGPoint.init(x: x, y: y), size: layoutAttribute.size)
      layoutMap.updateValue(layoutAttribute, forKey: indexPath)
      
    }
        //Don't bother refactoring until all block sizes and positions have been calculated
        contentSize = calculateContentSize()
  }
  
  //If this function can be taught to take a generic layoutmap or a custom class shared between the different graph types, it could be moved to the graph manager and used for all graphs
  //Don't bother refactoring until all block sizes and positions have been calculated
  fileprivate func calculateContentSize() -> CGSize {
    return CGSize.init(width: 1000.0, height: 1000.0)
  }
  
  fileprivate func calculateBlockSize(for indexPath: IndexPath) -> CGSize {
    var width: CGFloat = 0.0
    //let tempNode = inappropriateGraphManager.node(for: indexPath)!
    //let tempTask = tempNode.task
    //let tempTaskName = tempTask.title
    guard let node = inappropriateGraphManager.nodes[indexPath]
      else {
        fatalError("Node not found")
    }
    //let treePath = node?.treePath{
      let degree = node.treePath.count // Could this just use node.degree?
      //Find all treePaths which contain the entire treePath of the subject
      //CORRECTION:  MUST _BEGIN_WITH_ THE TREEPATH
      let otherNodes = inappropriateGraphManager.nodes.filter({$0.key != indexPath})
      let youngerNodes = otherNodes.filter({$0.value.treePath.count > degree})
      let descendantNodes = youngerNodes.filter({Array($0.value.treePath[..<degree]) == node.treePath})
      //Limit these to only treePaths of the generation under the subject
      let childNodes = descendantNodes.filter({$0.value.treePath.count == degree + 1})
      if childNodes.count == 0 {
          return CGSize.init(width: self.initialCellWidth, height: self.initialCellHeight)
      }
      let childIndexPaths = childNodes.keys
      for childNode in childNodes {
        if let childAttribute = childNode.value.layoutAttribute{
          let childWidth = childAttribute.size.width
          width += childWidth
        }
      }
    return CGSize.init(width: width, height: self.initialCellHeight)
  }
  
  fileprivate func calculateRow(for treePath: TreePath) -> CGFloat {
   return CGFloat(treePath.count - 1)
  }
  
  fileprivate func calculateY(for layoutAttribute: UICollectionViewLayoutAttributes, and row: CGFloat) -> CGFloat {
    return layoutAttribute.size.height * row
  }
  
  fileprivate func calculateX(for layoutAttribute: UICollectionViewLayoutAttributes) -> CGFloat {
    return layoutAttribute.size.width * CGFloat(layoutAttribute.indexPath.row)
  }
  

}

//  var preGenerationMap: [HierarchyGraphingNode] = []
//  //var generationMap = [CGFloat : [HierarchyGraphingNode]]()
//  var generationMap = [[HierarchyGraphingNode]]()
//  var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
//  var contentSize: CGSize = CGSize.init(width: 1000, height: 1000)
//  var maxGenerations: CGFloat = 0

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
