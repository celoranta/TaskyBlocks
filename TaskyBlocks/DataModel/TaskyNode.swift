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
  
  let task: Tasky
  let parent: Tasky?
  let nodeId = String(UUID().uuidString) + "N"

  init(fromTask task: Tasky, fromParent parent: Tasky?) {
    self.task = task
    self.parent = parent
  }
}

 
