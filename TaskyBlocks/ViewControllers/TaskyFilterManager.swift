//
//  TaskyFilterManager.swift
//  
//
//  Created by Chris Eloranta on 2018-04-12.
//

import UIKit

// Make this a singleton FilterManager object, which includes an active focus which can be edited by the user, and which is used to create the local views on each screen the user visits.  It may also save focii to a realm database for use with defaults or user settings.
// Or, more likely, just make a realm object (nope.  no enums)

// Protocol: TaskyFilterClient
// Have a var: taskyFilterManager: TaskyFilterManagerpointed to singleton manager
// - Have a method for processing a filter and a database into a set of taskyNode
// - Have a method for editing the shared
// - Have a method to call "filterWasEdited(by editor: TaskyFilterClient" on the TaskyFilter delegate field; which causes the Manager to grab the edited local Filter, assign it to the singleton's 'activeFilter' property, calculate a new filteredTaskySet, post it to "activeFilteredTaskySet" on the delegate.) The end of the filterWasEdited method should refresh the current view based on the new filter.

struct TaskFilter
{
  let context: FilterContext
  let selection: TaskyNode
  let focii: [FilterFocus]
}

struct FilterFocus
{
  let subject: TaskyNode
  let degree: RelationalDegreeGeneral
  let relation: RelationTypeGeneral
  let inclusion: RelationalInclusion
}

enum FilterContext
{
  case active, completed
}

class TaskyFilterManager: NSObject {
  
  //MARK: Properties
  static var shared = TaskyFilterManager(activeFilter: nil)
  var activeFilter: TaskFilter?

  //MARK: Init Method
  private init(activeFilter: TaskFilter?)
  {
    self.activeFilter = activeFilter
  }
  
}
