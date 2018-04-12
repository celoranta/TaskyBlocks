//
//  TaskyBlock2.swift
//  XibTry
//
//  Created by Chris Eloranta on 2018-04-02.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class TaskyBlock2: UIView {

  @IBOutlet var taskyBlock: UIView!
  @IBOutlet weak var blockyLabel: UILabel!
  var taskID = ""
  
  private func commonInit()
  {
    Bundle.main.loadNibNamed("TaskyBlock2", owner: self, options: nil)
    addSubview(taskyBlock)
    taskyBlock.frame = self.bounds
    blockyLabel.text = "<default>"
    taskyBlock.layer.borderWidth = 5.0
    taskyBlock.layer.cornerRadius = 25.00
    taskyBlock.autoresizingMask = [.flexibleHeight, .flexibleWidth]

  }
  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
}
