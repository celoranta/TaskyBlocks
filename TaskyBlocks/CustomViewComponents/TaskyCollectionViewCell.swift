//
//  TaskyCollectionViewCell.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-13.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class TaskyCollectionViewCell: UICollectionViewCell {



  @IBOutlet weak var blockyLabel: UILabel!
  
  
  var taskID = ""
  
  private func commonInit()
  {
    Bundle.main.loadNibNamed("TaskyBlock2", owner: self, options: nil)
   

    blockyLabel.text = "<default>"
    self.layer.borderWidth = 5.0
    self.layer.cornerRadius = 25.00
   // self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    let newSize = CGSize.init(width: 10, height: 10)
    let newPosition = CGPoint.init(x: 10, y: 10)
    let newRect = CGRect.init(origin: newPosition, size: newSize)
    self.frame = self.bounds
     let Newview = UIView.init(frame: newRect)
      self.addSubview(Newview)
  }
  /*
   // Only override draw() if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   override func draw(_ rect: CGRect) {
   // Drawing code
   }
   */
//
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    commonInit()
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//    commonInit()
//  }
}
