//
//  Tasky.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-06-15.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class Tasky: Object {
  
  /* Mark - ToDo:
   Migrate the following from TaskyNode:
   
 */

  @objc dynamic var taskId = String(UUID().uuidString) + "T"
}
