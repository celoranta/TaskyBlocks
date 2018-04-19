//
//  AddBlockViewCell.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-18.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class AddBlockViewCell: UICollectionViewCell {
    let image = UIImage.init(cgImage: #imageLiteral(resourceName: "greyPlus"))
  
  override func awakeFromNib()
  {
    let frame = CGRect.zero
    let cellView = UIImageView.init(frame: frame)
    let cell = UIView.init(frame: CGRect.zero)
    cell.addSubview(cellView)
    cell.translatesAutoresizingMaskIntoConstraints = false
    anchor1 centerXAnchor.
    
  }
}
