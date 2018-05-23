//
//  UIColor+Hex.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-23.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  //add error throws
  class func hex(hexString: String) -> UIColor {
    var cString: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }
    if ((cString.count) != 6) {
      return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}
