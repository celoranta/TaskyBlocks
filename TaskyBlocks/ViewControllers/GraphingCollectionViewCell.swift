

import UIKit

class GraphingCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var taskLabel: UILabel!
 
  
  func setupCellWith(task: TaskyNode)
  {
    
    
    taskLabel.text = "\(task.title)"
    self.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
    
    self.layer.borderWidth = 3
    self.layer.borderColor = UIColor.black.cgColor
    self.layer.cornerRadius = 5
    self.isUserInteractionEnabled = true
  }
}

