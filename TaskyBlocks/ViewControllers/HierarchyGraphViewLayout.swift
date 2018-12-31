

import UIKit

class HierarchyGraphViewLayout: GraphCollectionViewLayout {
 var contentSize: CGSize = CGSize.zero
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  let graphManager = GraphManager.sharedInstance
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var newAttributes: [UICollectionViewLayoutAttributes] = []
    for attribute in graphManager.nodes.compactMap({$0.value.layoutAttribute}) {
      if attribute.frame.intersects(rect) {
        newAttributes.append(attribute)
      }
    }
    return newAttributes
  }
  
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      return graphManager.nodes[indexPath]?.layoutAttribute
    }
  
  override func prepare() {
    //The graphmanager will probably end up being a singleton.
    graphManager.updateGraphs()
    for graphDataPoint in graphManager.nodes {
      let layoutAttribute = UICollectionViewLayoutAttributes.init(forCellWith: graphDataPoint.key)
      let node = graphDataPoint.value
      node.layoutAttribute = layoutAttribute
    }
    
    //Calculate a size and y value for each node
    for graphDataPoint in graphManager.nodes.sorted(by: {$0.value.treePath.count > $1.value.treePath.count}) {
      let indexPath = graphDataPoint.key
      let node = graphDataPoint.value
      if let layoutAttribute = node.layoutAttribute{
        layoutAttribute.size = calculateBlockSize(for: indexPath)
      }
      else {fatalError("layoutAttribute or treepath not found")}
      let row = calculateRow(for: node.treePath)
      node.y = calculateY(for: node.layoutAttribute, and: row)
      }
    
    calculateX(for: graphManager.hierarchyGraph, from: 0)
    
    
    
    
    for graphDataSet in graphManager.nodes {
      let node = graphDataSet.value
      guard let layoutAttribute = node.layoutAttribute
        else {
          fatalError("Node has no layoutAttribue value")
      }
      //node.x = calculateX(for: layoutAttribute)
      node.layoutAttribute.frame = CGRect.init(origin: CGPoint.init(x: node.x, y: node.y), size: layoutAttribute.size)
      //layoutMap.updateValue(layoutAttribute, forKey: indexPath)
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
    //let tempNode = graphManager.node(for: indexPath)!
    //let tempTask = tempNode.task
    //let tempTaskName = tempTask.title
    guard let node = graphManager.nodes[indexPath]
      else {
        fatalError("Node not found")
    }
    //let treePath = node?.treePath{
      let childNodes = childrenNodes(for: node)
      if childNodes.count == 0 {
          return CGSize.init(width: self.initialCellWidth, height: self.initialCellHeight)
      }
      //let childIndexPaths = childNodes.keys
      for childNode in childNodes {
        if let childAttribute = childNode.layoutAttribute{
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
  
//  fileprivate func recurseXOffsets(node: TaskyNode) {
//    var xRegister = 0
//    var siblingIndex = node.treePath.last
//    if let v
//    
//
//  }
  
  func calculateX(for siblings: [TaskyNode], from offset: CGFloat)  {
    var xRegister = offset
    for sibling in siblings {
      sibling.x = xRegister
      let width = sibling.layoutAttribute.size.width
      xRegister += width
      let children = childrenNodes(for: sibling)
      calculateX(for: children, from: sibling.x)
    }
  }
  
  func childrenNodes(for node: TaskyNode) -> [TaskyNode] {
  let degree = node.treePath.count // Could this just use node.degree?
  //Find all treePaths which contain the entire treePath of the subject
  //CORRECTION:  MUST _BEGIN_WITH_ THE TREEPATH
  let otherNodes = graphManager.nodes.filter({$0.value != node})
  let youngerNodes = otherNodes.filter({$0.value.treePath.count > degree})
  let descendantNodes = youngerNodes.filter({Array($0.value.treePath[..<degree]) == node.treePath})
  //Limit these to only treePaths of the generation under the subject
  let childNodes = descendantNodes.filter({$0.value.treePath.count == degree + 1})
    let children = Array(childNodes.values)
  return children
  }
}
