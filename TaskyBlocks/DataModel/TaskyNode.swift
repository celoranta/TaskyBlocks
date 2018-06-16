//
//  TaskyNode.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class TaskyNode: Object {
  
  @objc dynamic var task: Tasky!
  @objc dynamic var nodeId = String(UUID().uuidString) + "N"
  //Parent, Children, Sibling Order, and Collapse may be unnecessary due to the creation of a GraphManager
  
}

 
