

import UIKit

class GraphingCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var taskLabel: UILabel!
  var node: TaskyNode!


  func setupCell()
  {
    taskLabel.text = "\(node.task.title)"
    self.backgroundColor = node.task.calculateBlockColor()

    self.layer.borderWidth = 3
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.cornerRadius = 5
    self.isUserInteractionEnabled = true
  }
}

