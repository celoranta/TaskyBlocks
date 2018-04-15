//
//  TaskyGraphView.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class TaskyGraphView: UIScrollView {
  
  let blockyBuffer: CGFloat = 6.0
  let blockyAlpha: CGFloat = 0.8
  let blockyHeight: CGFloat = 100.00
  let blockyWidth: CGFloat = 200.00
  let margin: CGFloat = 25
  var filter = "completionDate == nil"

  func graphPriority()
  {
    let realm = try! Realm()
    let taskSet = realm.objects(TaskyNode.self).filter(filter)
    let contentView = UIView()
    
    let priorityArray = taskSet.sorted(by: { (prior, subsequent) -> Bool in
      if(prior.priorityApparent == subsequent.priorityApparent)
      {return prior.taskId < subsequent.taskId}
      else
      {return prior.priorityApparent > subsequent.priorityApparent}
    })
    
    var graphArray: [(Int,Int,TaskyNode)] = []
    var previousPriority:Double = 0.00
    var previousRow: Int = 0
    var previousColumn: Int = 0
    var column: Int = 0
    var row: Int = 0
    for task in priorityArray
    {
      if task.priorityApparent == previousPriority
      {
        column = previousColumn + 1
      }
      else
      {
        row = previousRow + 1
        column = 0
      }
      let entryRegister = (row: row - 1, column: column, task: task)
      graphArray.append(entryRegister)
      previousColumn = column
      previousRow = row
      previousPriority = task.priorityApparent
    }
    
    let horizSpacing = blockyWidth + blockyBuffer
    let verticalSpacing = blockyHeight + blockyBuffer
    
    for graphEntry in graphArray
    {
      let cell = TaskyBlock2()
      
      cell.frame.size.height = blockyHeight
      cell.frame.size.width = blockyWidth
      let HorizIndent = margin + CGFloat(Double(graphEntry.1) * Double(horizSpacing))
      let VertIndent = margin + CGFloat(Double(graphEntry.0) * Double(verticalSpacing))
      cell.frame.origin.x = HorizIndent
      cell.frame.origin.y = VertIndent
      cell.backgroundColor = UIColor.clear
      let task = graphEntry.2
      
      cell.blockyLabel.text = "\(task.title): \(task.priorityApparent)"
      cell.taskyBlock.alpha = blockyAlpha
      cell.taskID = task.taskId
      cell.taskyBlock.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
      
      
//      while contentView.subviews.count > 0
//      {
//        contentView.subviews[contentView.subviews.count - 1].removeFromSuperview()
//      }
      contentView.addSubview(cell)
    }
    
    let maxHeightBlock = (graphArray.max { (prior, consequent) -> Bool in
      prior.0 < consequent.0
    })
    let maxWidthBlock = (graphArray.max { (prior, consequent) -> Bool in
      prior.1 < consequent.1
    })

    let maxHeightInBlocks = maxHeightBlock!.0 + 1
    let maxWidthInBlocks = maxWidthBlock!.1 + 1

    let totalBlocksHeight = CGFloat((blockyHeight + blockyBuffer) * CGFloat(maxHeightInBlocks))
    let totalBlocksWidth = CGFloat((blockyWidth + blockyBuffer) * CGFloat(maxWidthInBlocks))
    
    let totalGraphHeight = totalBlocksHeight + (margin * 2)
    let totalGraphWidth = totalBlocksWidth + (margin * 2)

    let contentViewSize = CGSize.init(width: totalGraphWidth, height: totalGraphHeight)
    let contentViewOrigin = CGPoint.init(x: 0.0, y: 0.0)

    contentView.frame.size = contentViewSize
    contentView.frame.origin = contentViewOrigin
    
    while self.subviews.count != 0
    {
      self.subviews[0].removeFromSuperview()
    }
    self.addSubview(contentView)
    self.contentSize = contentView.frame.size
    self.layoutSubviews()
  }
}
