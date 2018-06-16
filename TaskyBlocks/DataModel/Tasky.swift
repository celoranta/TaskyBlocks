


//
//  Tasky.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-03-26.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift


class Tasky: Object /*Rename to Tasky*/
  
{
  //MARK: Realm ignored property list
  override static func ignoredProperties() -> [String]
  {
    return ["priorityInherited", "priorityConsequent", "isPrimal", "isActionable", "priorityApparent", "hierarchyWidthUnits"]
  }

  //MARK: Realm Value Properties
  @objc dynamic var title = "New Task"
  @objc dynamic var taskId = String(UUID().uuidString) + "T"
  @objc dynamic var taskDescription = ""
  @objc dynamic private (set) var taskDate = Date()
  @objc dynamic var completionDate: Date? = nil
  @objc dynamic var priorityDirectDefault: Double = (50 + Double(arc4random_uniform(100)/10000))
  @objc dynamic var isPermanent: Int = -1
   @objc dynamic var secondsElapsed: Int = 0
  
  //MARK: Realm Object Properties
  let parents = List<Tasky>()
  let children = LinkingObjects(fromType: Tasky.self, property: "parents")
  let antecedents = List<Tasky>() //Move to Task
  let consequents = LinkingObjects(fromType: Tasky.self, property: "antecedents")
  let priorityDirect: RealmOptional<Double> = RealmOptional.init()
  let priorityOverride: RealmOptional<Double> = RealmOptional.init()

  let secondsEstimated: RealmOptional<Int> = RealmOptional.init()

  
  //MARK: Calculated properties (ignored)

  var isPrimal: Bool  //included in 'ignore' by RealmSwift
  {
    return parents.count == 0
  }
  
  var isActionable: Bool  //included in 'ignore' by RealmSwift
  {
    return children.isEmpty
  }
  
  var priorityInherited: Double?  //included in 'ignore' by RealmSwift
  {
    get
    {
      return  (Array(parents).max { $0.priorityApparent < $1.priorityApparent})?.priorityApparent
    }
  }
  
   var priorityConsequent: Double?  //included in 'ignore' by RealmSwift
  {
        return  (Array(consequents).max { $0.priorityApparent < $1.priorityApparent})?.priorityApparent
  }
  
  var priorityApparent: Double
  {
    var priority = priorityDirect.value ?? priorityDirectDefault
    if let inherited = priorityInherited
    {
      priority = inherited < priority ? inherited : priority
    }
    if let consequent = priorityConsequent
    {
      priority = consequent > priority ? consequent : priority
    }
     return  priorityOverride.value ?? priority
  }
  
  var hierarchyGraphUnits: CGFloat {
    var units: CGFloat = 0.0
    switch self.children.count {
    case 0, 1: units = 1.0
    default: units = CGFloat(self.children.count) - CGFloat(0.8)
    }
    return units
  }
  
  var priorityDirectLocalCache: Double? = 50
  
  override var description: String
  {
    get
    {
      return self.title
    }
  }

  
  //MARK: Realm Key Property
  override static func primaryKey() -> String?
  {
    return "taskId"
  }
  
  //MARK: Init methods
    convenience init(with name: String = "New Task", and priority: Double = 50)
    {
      self.init()
      self.title = name
      print("New!")
      self.soundOff()
    }
  
  //Mark: Reporting Methods (for console debugging)
  func soundOff()
  {
    print("\nHi, I'm '\(self.title).'")
    print("My ID is: \(self.taskId)")
    print("My parents are: \(self.printMy(kin: RelationType.parents))")
    print("My children are: \(self.printMy(kin: RelationType.children))")
    print("My antecedents are: \(self.printMy(kin: RelationType.antecedents))")
    print("My consequents are: \(self.printMy(kin: RelationType.consequents))")
    if let unwrappedPriorityOverride = priorityOverride.value
    {
      print("My override priority is: \(unwrappedPriorityOverride)")
    }
    if let unwrappedPriorityDirect = priorityDirect.value
    { print("My direct priority is: \(unwrappedPriorityDirect)")
    }
    if let unwrappedPriorityConsequent = priorityConsequent
    {
      print("My consequent priority is: \(unwrappedPriorityConsequent)")
    }
    if let unwrappedPriorityInherited = self.priorityInherited
    {
      print("My inherited priority is: \(unwrappedPriorityInherited)")
    }
    print("My apparent priority is: \(self.priorityApparent)")
  }
  
  private func printMy(kin: RelationType) -> String
  {
    var returnString = ""
    switch kin
    {
    case RelationType.parents:
      for parent in parents
      {
        returnString += parent.title + " "
      }
    case RelationType.children:
      for child in children
      {
        returnString += child.title + " "
      }
    case RelationType.antecedents:
      for antecedent in antecedents
      {
        returnString += antecedent.title + " "
      }
    case RelationType.consequents:
      for consequent in consequents
      {
        returnString += consequent.title + " "
      }
    }
    return returnString
  }
  
  func calculateBlockColor() -> (UIColor)
  {
    // var blockColorString: String!
    var blockColor: UIColor!
    let priority = self.priorityApparent
    if self.isPermanent == 1
    {
      blockColor = UIColor.taskyPurple()
    }
    else
    {
      switch priority
      {
      case 66.00...100.00:
        blockColor = UIColor.taskyRed()
      case 33.00..<66.00:
        blockColor = UIColor.taskyYellow()
      case 0.00..<33.00:
        blockColor = UIColor.taskyGreen()
      default: blockColor = UIColor.black
      }
    }
    // blockColor = UIColor.hex(hexString: blockColorString)
    //blockColor = hexStringToUIColor(hex: blockColorString)
    return blockColor
  }

}

typealias TaskRecord = (taskId: String, priority: Double)

// MARK: Simple (original) relation enum
enum RelationType
{
  case parents, children, antecedents, consequents
}


//MARK: Auto-generated microvalue for determining a discrete sort value
extension Tasky {
  var uniqueKey: String {
    get {
      return "\(priorityApparent)\(taskId)"
    }
  }
}

