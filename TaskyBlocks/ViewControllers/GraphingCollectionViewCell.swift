

import UIKit

class GraphingCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var taskLabel: UILabel!
 
  
  func setupCellWith(task: Tasky)
  {
    
    
    taskLabel.text = "\(task.title)"
    self.backgroundColor = task.calculateBlockColor()
    
    self.layer.borderWidth = 3
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.cornerRadius = 5
    self.isUserInteractionEnabled = true
  }
}

