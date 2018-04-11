//
//  TaskyNodeManager.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-11.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class TaskyNodeManager: Object {
  
  func instantiateRealm()
  {
    do
    { let realm = try Realm()
    }
    catch let error as NSError
    { fatalError("Realm failed to instantiate.  Datestamp: \(Date())")
    }
  }
  //Node management here
  
  
  
  
  
  
  //Node management here
  func checkAndCompactRealm()
  {
    let config = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
      // totalBytes refers to the size of the file on disk in bytes (data + free space)
      // usedBytes refers to the number of bytes used by data in the file
      
      // Compact if the file is over 100MB in size and less than 50% 'used'
      let oneHundredMB = 100 * 1024 * 1024
      return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
    })
    do
    {
      let realm = try Realm()
    }
    catch let error as NSError
    {
      fatalError("Realm failed to instantiate during compaction routine.  Datestamp: \(Date())")
    }
  }
}

