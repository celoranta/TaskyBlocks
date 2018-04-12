//
//  TaskyGraphView.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class TaskyGraphView: UIScrollView {
  
  let blockyBuffer: CGFloat = 6.0
  let blockyAlpha: CGFloat = 0.8
  let blockyHeight: CGFloat = 100.00
  let blockyWidth: CGFloat = 200.00
  let margin: CGFloat = 25


  func graphPriorityWith(taskSet: Set<TaskyNode>)
  {
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
      cell.taskyBlock.backgroundColor = calculateBlockColorFrom(task: task)
      contentView.addSubview(cell)
    }
    
    let maxHeightBlock = (graphArray.max { (prior, consequent) -> Bool in
      prior.0 < consequent.0
    })
    let maxWidthBlock = (graphArray.max { (prior, consequent) -> Bool in
      prior.1 < consequent.1
    })

    //force unwraps are to be replaced
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
    
    self.addSubview(contentView)
    self.contentSize = contentView.frame.size
    self.layoutSubviews()
  }
  
  private func calculateBlockColorFrom(task: TaskyNode) -> (UIColor)
  {
    var blockColorString: String!
    var blockColor: UIColor!
    let priority = task.priorityApparent
    if task.title == "Be Happy"
    {
      blockColorString = colorString.purple.rawValue
    }
    else
    {
    switch priority
    {
    case 66.00...100.00:
      blockColorString = colorString.red.rawValue
    case 33.00..<66.00:
      blockColorString = colorString.yellow.rawValue
    case 0.00..<33.00:
      blockColorString = colorString.green.rawValue
    default: blockColor = UIColor.black
    }
    }
    blockColor = hexStringToUIColor(hex: blockColorString)
    return blockColor
  }
  enum colorString: String
  {
    case green = "#cfffc9"
    case red = "#fad3d3"
    case yellow = "#ffffa2"
    case purple = "dbd0f0"
  }
  
  func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }
    if ((cString.count) != 6) {
      return UIColor.gray
    }
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
  //  func createDescendingPointer()
  //  {
  //    let path = UIBezierPath()
  //    UIColor.black.setFill()
  //    path.fill()
  //    // Specify the point that the path should start get drawn.
  //    path.move(to: CGPoint(x: 100.0, y: 100.0))
  //
  //    // Create a line between the starting point and the bottom-left side of the view.
  //    path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height / 5))
  //
  //    // Create the bottom line (bottom-left to bottom-right).
  //    path.addLine(to: CGPoint(x: self.frame.size.width / 5, y: self.frame.size.height / 5))
  //
  //    // Create the vertical line from the bottom-right to the top-right side.
  //    path.addLine(to: CGPoint(x: self.frame.size.width / 5, y: 0.0))
  //
  //    // Close the path. This will create the last line automatically.
  //    path.close()
  //  }
  
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
  
}
