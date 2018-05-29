

import UIKit



class HierarchyGraphViewLayout: GraphCollectionViewLayout, GraphViewLayout {
  
//  struct TaskyBlock {
//    let task: TaskyNode
//    var widthFactor: CGFloat
//    var siblingIndex: CGFloat
//  }
  
  var preGenerationMap: [HierarchyGraphingNode] = []
  var generationMap = [CGFloat : [HierarchyGraphingNode]]()
  var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
  var contentSize: CGSize = CGSize.init(width: 1000, height: 1000)
  var maxGenerations: CGFloat = 0
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  
  var initialCellSpacing = CGFloat.init(0)
  var cellPlotSize: CGSize {
    return CGSize.init(width: initialCellSize.width + initialCellSpacing, height: initialCellSize.height + initialCellSpacing)
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
  
  private func center(rect1: CGSize, in rect2: CGRect) -> CGRect {
    let xOffset = 0.5 * (rect2.width - rect1.width)
    let yOffset = 0.5 * (rect2.height - rect1.height)
    let originX = rect2.origin.x + xOffset
    let originY = rect2.origin.y + yOffset
    let origin = CGPoint.init(x: originX, y: originY)
    return CGRect.init(origin: origin, size: rect1)
  }
  
  override func prepare() {
    super.prepare()
    let localDatasource = collectionViewLayoutDelegate.datasource()
    // map to hold task references as graphing units before relationships are calculated
    preGenerationMap = []
    for task in localDatasource {
      preGenerationMap.append(HierarchyGraphingNode.init(task: task))
    }
    print("/nPreGenerationMap: \n\(preGenerationMap)\n\n\n")
    generationMap = [:]
    for node in preGenerationMap {
      node.originYFactor = CGFloat(countOlderGenerations(of: node.task))
      if generationMap.keys.contains(node.originYFactor) {
        generationMap[node.originYFactor]!.append(node)
      }
      else {
        generationMap[node.originYFactor] = [node]
      }
    }
    print("/nGeneration map: \n\(generationMap)\n\n\n")
    
    //Create parent, sibling, and child references
    let generationQty = generationMap.count
    print("\nGeneration Count: \(generationQty)")
    for x in 0..<generationQty {
      let gen = CGFloat(x)
      let generationNodeCount = generationMap[gen]!.count
      for nodeIndex in 0..<generationNodeCount {
        for parent in generationMap[gen]![nodeIndex].task.parents {
          generationMap[gen]![nodeIndex].parents.append(hierarchyGraphingNodes(for: parent)[0])
          let newSiblingPath = SiblingPath.init(parent: hierarchyGraphingNodes(for: parent)[0], siblingIndex: CGFloat(parent.children.index(of: generationMap[gen]![nodeIndex].task)!))
          generationMap[gen]![nodeIndex].siblingPaths.append(newSiblingPath)
        }
        for child in generationMap[gen]![nodeIndex].task.children {
          generationMap[gen]![nodeIndex].children.append(hierarchyGraphingNodes(for: child)[0])
        }
      }
    }
    
    //Calculate Widths
    for x in stride(from: Int(generationQty - 1), to: 0, by: -1) {
      let gen = CGFloat(x)
      let generationNodeCount = generationMap[gen]!.count
      
      for nodeIndex in 0..<generationNodeCount {
        let task = generationMap[gen]![nodeIndex].task
        generationMap[gen]![nodeIndex].widthFactor = countChildlessDescendants(of: task) >= 1 ? countChildlessDescendants(of: task) : 1
        generationMap[gen]![nodeIndex].width = generationMap[gen]![nodeIndex].widthFactor * cellPlotSize.width
      }
    }
    for x in stride(from: Int(generationQty - 1), to: 0, by: -1) {
      let gen = CGFloat(x)
      let generationNodeCount = generationMap[gen]!.count
      for nodeIndex in 0..<generationNodeCount {
        let node = generationMap[gen]![nodeIndex]

        print("\nNode: \(node)")
        print("\nTask: \(node.task)")
        print("\nSiblingPaths: \(node.siblingPaths)")
        print("\nWidthFactor: \(node.widthFactor)")
      }
      
     //Chart by generation
      var maxWidth: CGFloat = 1
      for generation in generationMap {
        for node in generationMap[generation.key]!  {
          let wIndexInDataSource = collectionViewLayoutDelegate.datasource().index(of: node.task)
          if let indexInDataSource = wIndexInDataSource {
            let taskIndexPath = IndexPath.init(row: indexInDataSource, section: 0)
            let taskAttribute = UICollectionViewLayoutAttributes.init(forCellWith: taskIndexPath)
            let originY = cellPlotSize.height * node.originYFactor
            var originX: CGFloat = 0.0
            if node.parents.count > 0
            {
            originX = node.parents[0].originXFactor + sumOfPriorSiblingWidths(node: node)
            }
            let height: CGFloat = cellPlotSize.height
            let width: CGFloat = node.widthFactor == 0 ? 0.0 : (cellPlotSize.width * node.widthFactor)
            maxWidth = width > maxWidth ? width : maxWidth
            taskAttribute.frame = CGRect.init(x: originX, y: originY, width: width, height: height)
            layoutMap[taskIndexPath] = taskAttribute
          }
        }
      contentSize.width = maxWidth
      }
    }
    contentSize.height = CGFloat(generationMap.count) * cellPlotSize.height
    print("GenerationMap: \(generationMap)")
  }
  
  fileprivate func countOlderGenerations(of task: TaskyNode) -> CGFloat {
    for parent in task.parents {
      return 1.0 + countOlderGenerations(of: parent)
    }
    return 0
  }
  
  fileprivate func countChildlessDescendants(of task: TaskyNode) -> CGFloat {
    var childCount: CGFloat = 0.0
    for child in task.children
    {
      if child.children.count == 0 {
        childCount += CGFloat(1.0)
      }
      else {
        childCount += countChildlessDescendants(of: child)
      }
    }
    return childCount + CGFloat(1)
  }
  
  fileprivate func hierarchyGraphingNodes(for task: TaskyNode) -> [HierarchyGraphingNode] {
    var returnedNodes: [HierarchyGraphingNode] = []
    for hierarchyNode in self.preGenerationMap {
      if hierarchyNode.task == task {
        returnedNodes.append(hierarchyNode)
      }
    }
    return returnedNodes
  }
  
  fileprivate func sumOfPriorSiblingWidths(node: HierarchyGraphingNode) -> CGFloat {
    var count: CGFloat = 0
    if node.parents.count == 0 {
      return 0
    }
    else {

      for child in node.parents[0].children
      {
        if child.siblingPaths[0].siblingIndex! < node.siblingPaths[0].siblingIndex! {
          count += (child.siblingPaths[0].siblingIndex!)
        }
      }
    }
    return count
  }

  }
  



