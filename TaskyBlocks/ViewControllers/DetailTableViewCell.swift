//
//  DetailTableViewCell.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-06.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

  @IBOutlet weak var detailTypeLabel: UILabel!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
