

import UIKit

protocol CollectionViewLayoutDelegate {
  func datasource() -> [TaskyNode]
}

class PriorityGraphViewLayout: UICollectionViewLayout, GraphViewLayout {
  var collectionViewLayoutDelegate: CollectionViewLayoutDelegate!
  
  var maxTaskpriorityApparent: CGFloat = 100
  var minTaskpriorityApparent: CGFloat = 0
  var column = 0
  var localDatasource = Array(TaskyNodeEditor.sharedInstance.database)
  var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
  var contentSize: CGSize = CGSize.zero
  
  override var collectionViewContentSize: CGSize {
    return contentSize
  }
  var initialCellSize = CGSize(width: 150, height: 75)
  var initialCellSpacing = CGFloat.init(0)
  var cellPlotSize: CGSize
  {
    return CGSize.init(width: initialCellSize.width + initialCellSpacing, height: initialCellSize.height + initialCellSpacing)
  }
  
  //var collectionViewLayoutDelegate: CollectionViewLayoutDelegate!
  
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
    contentSize.height = UIScreen.main.bounds.height
   let localDatasource = collectionViewLayoutDelegate.datasource()
    let uMaxTask = localDatasource.max(by: {$0.priorityApparent < $1.priorityApparent})
    let uMinTask = localDatasource.max(by: {$0.priorityApparent > $1.priorityApparent})
    guard let maxTask = uMaxTask,
      let minTask = uMinTask
      else
    {
      fatalError("datasource does not include max and min tasks")
    }
    layoutMap = [:]
    
    let maxIndexPath = IndexPath.init(row: collectionViewLayoutDelegate.datasource().index(of: maxTask)!, section: 0)
    let maxAttribute = UICollectionViewLayoutAttributes.init(forCellWith: maxIndexPath)
    maxTaskpriorityApparent = CGFloat(maxTask.priorityApparent)
    let maxOrigin = CGPoint.init(x: 0, y: 0)
    maxAttribute.frame = CGRect.init(origin: maxOrigin, size: cellPlotSize)
    //maxAttribute.bounds = center(rect1: initialCellSize, in: maxAttribute.frame)
    layoutMap[maxIndexPath] = maxAttribute
    
    var minAttribute: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes.init()
    if maxTask != minTask
    {
      let minIndexPath = IndexPath.init(row: collectionViewLayoutDelegate.datasource().index(of: minTask)!, section: 0)
      minAttribute = UICollectionViewLayoutAttributes.init(forCellWith: minIndexPath)
      minTaskpriorityApparent = CGFloat(minTask.priorityApparent)
      let minFrameX = CGFloat.init(initialCellSpacing)
      let minFrameY = CGFloat.init(contentSize.height - cellPlotSize.height)
      let minOrigin = CGPoint.init(x: minFrameX, y: minFrameY)
      minAttribute.frame = CGRect.init(origin: minOrigin, size: cellPlotSize)
      //minAttribute.bounds = center(rect1: initialCellSize, in: minAttribute.frame)
      layoutMap[minIndexPath] = minAttribute
    }
    var unmappedTasks = localDatasource.sorted(by: {$0.priorityApparent > $1.priorityApparent})
    for task in unmappedTasks
    {
      print(task.priorityApparent)
    }
    let maxIndex = unmappedTasks.index(of: maxTask)!
    unmappedTasks.remove(at: maxIndex)
    let minIndex = unmappedTasks.index(of: minTask)!
    unmappedTasks.remove(at: minIndex)
    column = 0
    var previousTaskAttribute = maxAttribute
    var futureColumnTasks: [TaskyNode] = []
    repeat
    {
      futureColumnTasks = []
      for task in unmappedTasks
      {
        let wIndexInDataSource = collectionViewLayoutDelegate.datasource().index(of: task)
        if let indexInDataSouce = wIndexInDataSource
        {
          let taskIndexPath = IndexPath.init(row: indexInDataSouce, section: 0)
          let taskAttribute = UICollectionViewLayoutAttributes.init(forCellWith: taskIndexPath)
          let taskOrigin = origin(for: task, at: column)
          taskAttribute.frame = CGRect.init(origin: taskOrigin, size: cellPlotSize)
          if !taskAttribute.frame.intersects(previousTaskAttribute.frame) && !taskAttribute.frame.intersects(minAttribute.frame)
          {
            print("Entering \(task.priorityApparent) at origin \(taskOrigin.x), \(taskOrigin.y); size: \(taskAttribute.size.width), \(taskAttribute.size.height)")
            layoutMap[taskIndexPath] = taskAttribute
            previousTaskAttribute = taskAttribute
          }
          else
          {
            futureColumnTasks.append(task)
            print("saved for next column: \(task.priorityApparent)")
          }
        }
      }
      unmappedTasks = futureColumnTasks
      column += 1
    }
      while futureColumnTasks.count > 0
    contentSize.width = cellPlotSize.width * CGFloat(column)
  }
  
  fileprivate func origin(for task: TaskyNode, at column: Int) -> CGPoint
  {
    let xOffset = CGFloat.init(column) * cellPlotSize.width
    let normalizedpriorityApparent = CGFloat(task.priorityApparent) - minTaskpriorityApparent
    let range = CGFloat(maxTaskpriorityApparent - minTaskpriorityApparent)
    let yOffset = ((CGFloat(1) - normalizedpriorityApparent / range) * (contentSize.height - cellPlotSize.height))
    print ("Origin for task: \(task) set to \(xOffset) by \(yOffset)")
    return CGPoint.init(x: xOffset, y: yOffset)
  }
  
}
