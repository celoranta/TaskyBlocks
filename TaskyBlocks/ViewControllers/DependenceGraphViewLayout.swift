


import UIKit



class DependenceGraphViewLayout: GraphCollectionViewLayout, GraphViewLayout {
  
  struct seekRegister {
    let task: TaskyNode
    var ungraphedConsequents: [TaskyNode]
    let isVirginal: Bool = true

    
    init(task: TaskyNode)
    {
      self.task = task
      self.ungraphedConsequents = Array(task.consequents)
    }
  }
  
  var column: CGFloat = 0.0
  var row: CGFloat = 0.0
  var localDatasource = Array(TaskyNodeEditor.sharedInstance.database)
  var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
  var contentSize: CGSize = CGSize.init(width: 1000, height: 1000)
  var seekingArray: [seekRegister] = []
  var seedTask: TaskyNode!
  
  override var collectionViewContentSize: CGSize {
    return contentSize
  }

  var initialCellSpacing = CGFloat.init(0)
  var cellPlotSize: CGSize {
    return CGSize.init(width: initialCellSize.width + initialCellSpacing, height: initialCellSize.height + initialCellSpacing)
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var newAttributes: [UICollectionViewLayoutAttributes] = []
    for attribute in layoutMap {
      if attribute.value.frame.intersects(rect) {
        newAttributes.append(attribute.value)
      }
    }
    return newAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return layoutMap[indexPath]
  }
  
  
  private func center(rect1: CGSize, in rect2: CGRect) -> CGRect
  {
    let xOffset = 0.5 * (rect2.width - rect1.width)
    let yOffset = 0.5 * (rect2.height - rect1.height)
    let originX = rect2.origin.x + xOffset
    let originY = rect2.origin.y + yOffset
    let origin = CGPoint.init(x: originX, y: originY)
    return CGRect.init(origin: origin, size: rect1)
  }
  
  override func prepare() {
    super.prepare()
    
    //set default values (to be moved to a method)
    contentSize = CGSize.init(width: 1500, height: 1500)
    layoutMap = [:]
    column = 0.0
    row = 0.0
    seekingArray = []
    seedTask = TaskyNodeEditor.sharedInstance.newTask()
    
    guard let seedTask = seedTask
      else {
        fatalError("Error in Seed Task Creation")
    }
    TaskyNodeEditor.sharedInstance.changeTitle(task: seedTask, to: "seedTask")
    TaskyNodeEditor.sharedInstance.updateTaskDescription(for: seedTask, with: "Temporary Task used in the graphing of dependence layout.  Should always be automatically deleted by the graphing process before appearing in the UI")
    
    let maxDependeesTask = localDatasource.max(by: {dependeeLevelsQty(of: $0) < dependeeLevelsQty(of: $1)})
    var maxLevelsQty = 0
    
    if let uMaxDependeesTask = maxDependeesTask {
      maxLevelsQty = dependeeLevelsQty(of: uMaxDependeesTask)
    }
    
    var dependeeModel: [[TaskyNode]] = []
    for _ in 0...maxLevelsQty {
      dependeeModel.append([])
    }
    print("Printing test Empty Data Model \(dependeeModel)")
    
    for task in localDatasource {
      let dependeelevelQty = dependeeLevelsQty(of: task)
      dependeeModel[dependeelevelQty].append(task)
    }
    
    
    for task in dependeeModel[0] {
      TaskyNodeEditor.sharedInstance.add(task: task, asConsequentTo: seedTask)
    }
    seekingArray = [(seekRegister.init(task: seedTask))]
    
    
    //Graphing Process
    
    while seekingArray.count > 0
    {
      let lastIndex = seekingArray.endIndex - 1
      //remove the last task from the array if it has no consequents
      if seekingArray[lastIndex].ungraphedConsequents.count == 0 {
        seekingArray.removeLast()
        column -= 1
      }
      else {
        column += 1
        if seekingArray[lastIndex].isVirginal {
          row += 1
        }
        let task = seekingArray[lastIndex].ungraphedConsequents.removeFirst()
        let graphingRegister = seekRegister.init(task: task)
        seekingArray.append(graphingRegister)
        
        if let indexInDataSource = localDatasource.index(of: task) {
          let indexPath = IndexPath.init(row: indexInDataSource, section: 0)
          let attribute = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
          attribute.frame.size = self.cellPlotSize
          attribute.frame.origin = CGPoint.init(x: cellPlotSize.width * column, y: cellPlotSize.height * row)
          layoutMap[indexPath] = attribute
        }
      }
    }
    TaskyNodeEditor.sharedInstance.removeAsAntecedentToAll(task: self.seedTask)
    TaskyNodeEditor.sharedInstance.delete(task: self.seedTask)
    self.seedTask = nil
  }
  
  fileprivate func dependeeLevelsQty(of task: TaskyNode) -> Int {
    if task.antecedents.count > 0 {
      for task in task.antecedents {
        return dependeeLevelsQty(of: task) + 1
      }
    }
    else {
      return 0
    }
    return 1
  }
  

}
