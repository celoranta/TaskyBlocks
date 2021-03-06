//
//  TaskyBlockLibrary.swift
//  
//
//  Created by Chris Eloranta on 2018-04-11.
//

import Foundation
import RealmSwift

enum Direction: String
{
case up = "up", down = "down"
}

enum colorString: String
{
  case green = "#cfffc9"
  case red = "#fad3d3"
  case yellow = "#ffffa2"
  case purple = "dbd0f0"
}

class TaskyBlockLibrary
{
  class func calculateBlockColorFrom(task: TaskyNode) -> (UIColor)
  {
    var blockColorString: String!
    var blockColor: UIColor!
    let priority = task.priorityApparent
    if task.isPermanent == 1
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

  class func hexStringToUIColor(hex:String) -> UIColor {
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
}

typealias TaskRecord = (taskId: String, priority: Double)

// MARK: Simple (original) relation enum
enum RelationType
{
  case parents, children, antecedents, consequents
}

// MARK: Comprehensive (not original) relation data types

enum EditType
{
  case attach, remove
}

enum RelationTypeGeneral
{
  case ancestors, descendents, siblings
}

enum RelationalDegreeGeneral
{
  case immediate, subsequent, ultimate, penultimate, numericDisplacment
}

enum RelationalInclusion
{
  case exclusive, inclusive
}

