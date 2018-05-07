//
//  PriorityCollectionViewLayout.swift
//  PriorityViewTest
//
//  Created by Chris Eloranta on 2018-05-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class PriorityCollectionViewLayout: CollectionViewLayout {
  var maxTaskPriority: CGFloat = 100
  var minTaskPriority: CGFloat = 0
  var column = 0
  
  override func prepare() {
    contentSize.height = UIScreen.main.bounds.height
    let localDatasource = collectionViewLayoutDelegate.datasource(for: self)
    let uMaxTask = localDatasource.max(by: {$0.priority < $1.priority})
    let uMinTask = localDatasource.max(by: {$0.priority > $1.priority})
    guard let maxTask = uMaxTask,
      let minTask = uMinTask
      else
    {
      fatalError("datasource does not include max and min tasks")
    }
    layoutMap = [:]
    
    let maxIndexPath = IndexPath.init(row: collectionViewLayoutDelegate.datasource(for: self).index(of: maxTask)!, section: 0)
    let maxAttribute = UICollectionViewLayoutAttributes.init(forCellWith: maxIndexPath)
    maxTaskPriority = CGFloat(maxTask.priority)
    let maxOrigin = CGPoint.init(x: 0, y: 0)
    maxAttribute.frame = CGRect.init(origin: maxOrigin, size: cellPlotSize)
    //maxAttribute.bounds = center(rect1: initialCellSize, in: maxAttribute.frame)
    layoutMap[maxIndexPath] = maxAttribute
    
    var minAttribute: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes.init()
    if maxTask != minTask
    {
      let minIndexPath = IndexPath.init(row: collectionViewLayoutDelegate.datasource(for: self).index(of: minTask)!, section: 0)
      minAttribute = UICollectionViewLayoutAttributes.init(forCellWith: minIndexPath)
      minTaskPriority = CGFloat(minTask.priority)
      let minFrameX = CGFloat.init(initialCellSpacing)
      let minFrameY = CGFloat.init(contentSize.height - cellPlotSize.height)
      let minOrigin = CGPoint.init(x: minFrameX, y: minFrameY)
      minAttribute.frame = CGRect.init(origin: minOrigin, size: cellPlotSize)
      //minAttribute.bounds = center(rect1: initialCellSize, in: minAttribute.frame)
      layoutMap[minIndexPath] = minAttribute
    }
    var unmappedTasks = localDatasource.sorted(by: {$0.priority > $1.priority})
    for task in unmappedTasks
    {
      print(task.priority)
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
        let wIndexInDataSource = collectionViewLayoutDelegate.datasource(for: self).index(of: task)
        if let indexInDataSouce = wIndexInDataSource
        {
          let taskIndexPath = IndexPath.init(row: indexInDataSouce, section: 0)
          let taskAttribute = UICollectionViewLayoutAttributes.init(forCellWith: taskIndexPath)
          let taskOrigin = origin(for: task, at: column)
          taskAttribute.frame = CGRect.init(origin: taskOrigin, size: cellPlotSize)
          if !taskAttribute.frame.intersects(previousTaskAttribute.frame) && !taskAttribute.frame.intersects(minAttribute.frame)
          {
            print("Entering \(task.priority) at origin \(taskOrigin.x), \(taskOrigin.y); size: \(taskAttribute.size.width), \(taskAttribute.size.height)")
            layoutMap[taskIndexPath] = taskAttribute
            previousTaskAttribute = taskAttribute
          }
          else
          {
            futureColumnTasks.append(task)
            print("saved for next column: \(task.priority)")
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
    let normalizedPriority = CGFloat(task.priority) - minTaskPriority
    let range = CGFloat(maxTaskPriority - minTaskPriority)
    let yOffset = ((CGFloat(1) - normalizedPriority / range) * (contentSize.height - cellPlotSize.height))
    print ("Origin for task: \(task) set to \(xOffset) by \(yOffset)")
    return CGPoint.init(x: xOffset, y: yOffset)
  }

}
