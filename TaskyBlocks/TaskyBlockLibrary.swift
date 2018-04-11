//
//  TaskyBlockLibrary.swift
//  
//
//  Created by Chris Eloranta on 2018-04-11.
//

import Foundation


typealias TaskRecord = (taskId: String, priority: Double)

enum RelationType
{
  case parents, children, antecedents, consequents
}
