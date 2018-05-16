

import UIKit



class HierarchyGraphViewLayout: GraphCollectionViewLayout, GraphViewLayout {
  
  struct TaskHierarchyData {
    let task: TaskyNode
    var previousGenerations: CGFloat = 0
    var block: UIView? = nil
    var chunk: UIView? = nil
    var graphView: UIView? {
      get {
        if self.chunk != nil {return chunk}
        else if self.block != nil {return block}
        else {return nil}
      }
    }
    var graphViewOffset: CGFloat = 0
    init(with task: TaskyNode) {
      self.task = task
    }
  }
  
  
  var localDatasource = Array(TaskyNodeEditor.sharedInstance.database)
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
    contentSize = CGSize.init(width: 1500, height: 1500)
    layoutMap = [:]
    
    var hierarchyDataSet: [TaskHierarchyData] = []
    
    for task in localDatasource {
      print("\(task.title) has \(countOlderGenerations(of: task)) previous generations")
      var dataPoint = TaskHierarchyData.init(with: task)
      dataPoint.previousGenerations = CGFloat(countOlderGenerations(of: task))
      hierarchyDataSet.append(dataPoint)
      self.maxGenerations = dataPoint.previousGenerations > self.maxGenerations ? dataPoint.previousGenerations : self.maxGenerations
    }
    
    print(hierarchyDataSet)
    var dataByGeneration: [[TaskHierarchyData]] = [[]]
    for i in stride(from: Int(maxGenerations), to: 0, by: -1)  {
      print(i - 1)
      var generationData: [TaskHierarchyData] = []
      let generation = hierarchyDataSet.filter({Int($0.previousGenerations) == i - 1})
      let generationCount = generation.count
      for datapointIndex in 0..<generationCount {
        var dataPoint = generation[datapointIndex]
        let defaultSize = initialCellSize
        let defaultOrigin = CGPoint.zero
        let defaultFrame = CGRect.init(origin: defaultOrigin, size: defaultSize!)
        dataPoint.block = UIView.init(frame: defaultFrame)
        if dataPoint.task.children.count > 0 {

          var chunk: UIView? = nil
          var childArray: [TaskHierarchyData] = []
          print("Parent Task \(dataPoint.task.title) has children:")
          for child in dataPoint.task.children {
            let childDataPoint = hierarchyDataSet.first(where: {$0.task == child})!
            print(childDataPoint.task.title)
            childArray.append(childDataPoint)
          }
          let maxChildChunkHeight = (childArray.max(by: {$0.graphView!.frame.height > $1.graphView!.frame.height})!.graphView!.frame.height)
          let totalChildChunkWidth = childArray.reduce(0) {$0 + $1.graphView!.frame.width}
          var chunkSize = CGSize.init(width: totalChildChunkWidth, height: maxChildChunkHeight + defaultSize!.height)
          let chunkFrame = CGRect.init(origin: CGPoint.zero, size: chunkSize)
          chunk = UIView.init(frame: chunkFrame)

          

            
//            if let graphingItem = childDataPoint.graphView
//            {
//              maxChildChunkHeight = graphingItem.frame.height > maxChildChunkHeight ? graphingItem.frame.height : maxChildChunkHeight
//              totalChildChunkWidth += graphingItem.frame.width
//              childDataPoint.graphViewOffset = xOffset
//
//              xOffset += childDataPoint.graphView!.frame.width
//            }
          }
        }
        
        
        for task in localDatasource {
          if let indexInDataSource = localDatasource.index(of: task) {
            let indexPath = IndexPath.init(row: indexInDataSource, section: 0)
            let attribute = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            attribute.frame.size = self.cellPlotSize
            attribute.frame.origin = CGPoint.init(x: 0, y: cellPlotSize.height * CGFloat(indexPath.row))
            layoutMap[indexPath] = attribute
          }
        }
      }
    }
  
  
  fileprivate func countOlderGenerations(of task: TaskyNode) -> Int {
    for parent in task.parents {
      return 1 + countOlderGenerations(of: parent)
    }
    return 0
  }
  
}
