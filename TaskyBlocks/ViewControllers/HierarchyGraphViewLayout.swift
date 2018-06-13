

import UIKit



class HierarchyGraphViewLayout: GraphCollectionViewLayout, GraphViewLayout {
  
  
  var preGenerationMap: [HierarchyGraphingNode] = []
  //var generationMap = [CGFloat : [HierarchyGraphingNode]]()
  var generationMap = [[HierarchyGraphingNode]]()
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
    print("\n\n---PREPARING HIERARCHY VIEW LAYOUT---\n\n")
    let localDatasource = collectionViewLayoutDelegate.datasource()
    
    // -- Re-Create Generational Data Structure with Graphing Node objects
    
    //Create graphing nodes for primal generation of tasks
    let primalTasks = localDatasource.filter({$0.parents.count == 0})
    print("Primal Tasks: \(primalTasks)")
    generationMap = [[]]
    for task in primalTasks {
      let graphingNode = HierarchyGraphingNode.init(task: task, parent: nil)
      generationMap[0].append(graphingNode)
    }
    
    var currentGeneration = generationMap[0]
    while createGeneration(following: currentGeneration).count > 0 {
      let newGeneration = createGeneration(following: currentGeneration)
      generationMap.append(newGeneration)
      currentGeneration = newGeneration
    }
    
    for generation in generationMap {
      for node in generation {
        node.originYFactor = CGFloat(generationMap.index(of: generation)!)
      }
    }
    
    //Create parent, sibling, and child references
    let generationQty = generationMap.count
    print("\nGeneration Count: \(generationQty)")
    //Traverse all nodes in the generation map
    for x in 0..<generationQty {
      let generationNodeCount = generationMap[x].count
      for nodeIndex in 0..<generationNodeCount {
        let node = generationMap[x][nodeIndex]
        //And all parents of each node task
        for parent in node.task.parents {
          if parent.parents.count > 0 {
            //And retrieve/append a reference to each parent node using one of ITS parents
            if let newParentNodeReference = hierarchyGraphingNode(for: parent, parent: parent.parents[0]) {
              node.parents.append(newParentNodeReference)
            }
          }
            //Unless it is primal, in which case use nil as the parent
          else {
            if let newParentNodeReference = hierarchyGraphingNode(for: parent, parent: nil) {
              node.parents.append(newParentNodeReference)
            }
          }
        }
        
        //retrive and append child references
        for child in node.task.children {
          if let newChildNodeReference = hierarchyGraphingNode(for: child, parent: node.task) {
            node.children.append(newChildNodeReference)
          }
        }
      }
    }
    
    //Calculate Widths
    for x in stride(from: Int(generationQty - 1), through: 0, by: -1) {
      // let gen = CGFloat(x)
      let generationNodeCount = generationMap[x].count
      for nodeIndex in 0..<generationNodeCount {
        let task = generationMap[x][nodeIndex].task
        generationMap[x][nodeIndex].widthFactor = countChildlessDescendants(of: task) >= 2 ? countChildlessDescendants(of: task) : 1
        generationMap[x][nodeIndex].width = generationMap[x][nodeIndex].widthFactor * cellPlotSize.width
      }
    }
    
    //Chart by generation
    var maxWidth: CGFloat = 1
    var primalXPositionRegister: CGFloat = 0.0
    for generation in generationMap {
      for node in generation {
        let wIndexInDataSource = collectionViewLayoutDelegate.datasource().index(of: node.task)
        if let indexInDataSource = wIndexInDataSource {
          let taskIndexPath = IndexPath.init(row: indexInDataSource, section: 0)
          let taskAttribute = UICollectionViewLayoutAttributes.init(forCellWith: taskIndexPath)
          let originY = cellPlotSize.height * node.originYFactor
          var originX: CGFloat = 0.0
          if node.parents.count == 0 {
            originX = primalXPositionRegister
            primalXPositionRegister += node.width
          }
          else {
            originX = node.parents[0].childXPositionRegister
            node.parents[0].childXPositionRegister += node.width
          }
          node.childXPositionRegister = originX
          node.originXFinal = originX
          let height: CGFloat = cellPlotSize.height
          let width: CGFloat = node.widthFactor == 0 ? 0.0 : (cellPlotSize.width * node.widthFactor)
          maxWidth = width > maxWidth ? width : maxWidth
          taskAttribute.frame = CGRect.init(x: originX, y: originY, width: width, height: height)
          layoutMap[taskIndexPath] = taskAttribute
        }
      }
    }
    var calcContentWidth: CGFloat = 0.0
    for generation in generationMap {
      var generationWidth: CGFloat = 0.0
      for node in generation {
        generationWidth += node.width
      }
      calcContentWidth = generationWidth > calcContentWidth ? generationWidth : calcContentWidth
    }
    
    let calcContentHeight = CGFloat(generationMap.count) * cellPlotSize.height
    contentSize = CGSize.init(width: calcContentWidth, height: calcContentHeight)
    print("GenerationMap: \(generationMap)\n")
    //print("LayoutMap: \(layoutMap)")
    
    //MARK: TODO - Once single parenthood graphs properly, add a step just before graphing which replicates an entire downstream tree at each multiple parent, and creates a separate graphing node for each.
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
    return childCount
  }
  
  fileprivate func hierarchyGraphingNode(for task: TaskyNode, parent: TaskyNode?) -> HierarchyGraphingNode? {
    if let parent = parent {
      for generation in generationMap {
        for node in generation {
          if node.task.parents.contains(parent) && node.task == task {
            return node
          }
        }
      }
    }
    else if generationMap[0].filter({$0.task == task}).count > 0 {
      for node in generationMap[0] {
        if node.task == task {
          return node
        }
      }
    }
    return nil
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
  
  fileprivate func xOffset(per siblingPath: SiblingPath) -> CGFloat {
    var offset: CGFloat = 0.0
    if let parent = siblingPath.parent {
      for child in parent.children {
        for childSiblingPath in child.siblingPaths {
          if childSiblingPath.siblingIndex! < siblingPath.siblingIndex! {
            offset += child.width
          }
        }
      }
      offset += parent.width
    }
    return offset
  }
  
  fileprivate func createGeneration(following generation: [HierarchyGraphingNode]) -> [HierarchyGraphingNode] {
    var newGeneration: [HierarchyGraphingNode] = []
    for node in generation {
      for child in node.task.children {
        newGeneration.append(HierarchyGraphingNode.init(task: child, parent: node))
      }
    }
    return newGeneration
  }
}
