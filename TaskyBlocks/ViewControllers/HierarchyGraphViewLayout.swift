

import UIKit



class HierarchyGraphViewLayout: GraphCollectionViewLayout, GraphViewLayout {
  
  struct TaskyBlock {
    let task: TaskyNode
    var widthFactor: CGFloat
    var siblingIndex: CGFloat
  }
  
  
  var generationMap = [CGFloat : [TaskyBlock]]()
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
    generationMap = [:]
    for task in localDatasource {
      var index: CGFloat
      if task.parents.count > 0 {
      index = CGFloat(task.parents[0].index(ofAccessibilityElement: task))
      }
      else {
        index = 0.0
      }
      let block = TaskyBlock.init(task: task, widthFactor: max(self.countChildlessDescendants(of: task), CGFloat(1)), siblingIndex: index)
      let generation = self.countOlderGenerations(of: task)
      if !generationMap.keys.contains(generation)
      {
        generationMap[generation] = [TaskyBlock]()
      }
      guard generationMap[generation] != nil
        else {fatalError("Fatal Error: Empty Generation Entry Not Created")}
      generationMap[generation]!.append(block)
    }
    // Should replace the following with mapping function
    
    var maxGenWidth: CGFloat = 0
    for generation in generationMap
    {
      var genWidth:CGFloat = 0
      for entry in generation.value
      {
        genWidth += entry.widthFactor
      }
      if genWidth >= maxGenWidth
      {
        maxGenWidth = genWidth
      }
    }
    var gensAtMaxWidth: [CGFloat] = []
    var genWidth: CGFloat = 0.0
    for generation in generationMap
    {
      for entry in generation.value
      {
        genWidth += entry.widthFactor
      }
      if genWidth == maxGenWidth
      {
        gensAtMaxWidth.append(generation.key)
      }
      genWidth = 0.0
    }
    contentSize.width = maxGenWidth * self.cellPlotSize.width
    contentSize.height = CGFloat(generationMap.count) * self.cellPlotSize.height
    print("MaxGenWidth: \(maxGenWidth)")
    print("Gens at MaxGenWidth: \(gensAtMaxWidth)")
    print("generation map: \n \(generationMap)")
    
    for generation in generationMap {
      for block in generation.value {
        if let indexInDataSource = localDatasource.index(of: block.task) {
          let indexPath = IndexPath.init(row: indexInDataSource, section: 0)
          let attribute = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
          attribute.frame.size = self.cellPlotSize
          attribute.frame.origin = CGPoint.init(x: cellPlotSize.width * block.siblingIndex, y: (cellPlotSize.height * generation.key))
          layoutMap[indexPath] = attribute
        }
      }
    }
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
}


