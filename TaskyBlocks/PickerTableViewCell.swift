//
//  PickerTableViewCell.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-07.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {
  @IBOutlet weak var checkMarkButton: UIButton!
  @IBOutlet weak var taskTitleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()

    self.checkMarkButton.setTitle("\u{2713}", for: .normal)
    self.checkMarkButton.setTitle("-", for: .selected)
    
    self.taskTitleLabel.text = "<default task title>"
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
