//
//  GraphViewGestureDelegate.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2019-01-03.
//  Copyright © 2019 Christopher Eloranta. All rights reserved.
//

import UIKit

class GraphViewGestureDelegate: NSObject, UIGestureRecognizerDelegate {

  
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  
}
