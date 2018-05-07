//
//  TaskyNode.swift
//  PriorityViewTest
//
//  Created by Chris Eloranta on 2018-05-01.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class TaskyNode: NSObject {
  
  var priority: Double = Double(arc4random_uniform(100))
  var parents: [TaskyNode] = []
  var dependees: [TaskyNode] = []
}
