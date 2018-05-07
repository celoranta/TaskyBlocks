//
//  TaskCollectionViewCell.swift
//  PriorityViewTest
//
//  Created by Chris Eloranta on 2018-05-01.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class TaskCollectionViewCell: UICollectionViewCell {
  
  
  @IBOutlet weak var cellLabel: UILabel!
  let cellSpacing: CGFloat = 2
  
  func setupCellWith(task: TaskyNode)
  {
    cellLabel.text = "\(task.priority)"
    self.backgroundColor = UIColor.cyan
    self.layer.borderWidth = 3
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.cornerRadius = 5
  }
}
