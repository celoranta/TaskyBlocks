//
//  MasterGraphingCollectionViewCell.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-16.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class MasterGraphingCollectionViewCell: UICollectionViewCell {
  

  let borderColor = UIColor.darkGray.cgColor
  static var blockyWidth: CGFloat = 123.5
  static var blockyHeight: CGFloat
  {get
  {return blockyWidth * 0.5
    }
  }
  var blockyBorder: CGFloat
  {get
  {return MasterGraphingCollectionViewCell.blockyHeight * 0.05
    }
  }
  var blockyRadius: CGFloat
  {get
  {return MasterGraphingCollectionViewCell.blockyHeight * 0.2
    }
  }
  
  @IBOutlet weak var cellTitleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    layer.borderColor = borderColor
    autoresizesSubviews = true
    layer.borderWidth = blockyBorder
    layer.cornerRadius = blockyRadius
    cellTitleLabel.frame = bounds
    cellTitleLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    cellTitleLabel.textAlignment = .center
    cellTitleLabel.numberOfLines = 0
    cellTitleLabel.lineBreakMode = .byWordWrapping
    cellTitleLabel.font.withSize(MasterGraphingCollectionViewCell.blockyWidth / 12)
  }
  
}
