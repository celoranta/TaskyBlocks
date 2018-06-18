//
//  TaskyNode.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class TaskyNode: NSObject {
  
  var task: Tasky
//  let nodeId = String(UUID().uuidString) + "N"

  convenience init(task: Tasky) {
    self.init(task: task)
  }
}

 
