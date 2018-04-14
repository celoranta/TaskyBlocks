//
//  PriorityViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-13.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

class PriorityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

  let items = ["One", "Two"]
  var realm: Realm!
  var activeTaskySet: Results<TaskyNode>!
  let filter = "completionDate != nil"
  

  let blockyAlpha: CGFloat = 0.8
  let blockyHeight: CGFloat = 100.00
  let blockyWidth: CGFloat = 200.00
    //let blockyBuffer: CGFloat = 6.0
  //let margin: CGFloat = 25
  //var filter = "completionDate == nil"
  
  @IBOutlet weak var priorityCollectionView: UICollectionView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      realm = try! Realm()
      activeTaskySet = realm.objects(TaskyNode.self)//.filter(filter)
    }
  
  override func viewWillAppear(_ animated: Bool) {
    priorityCollectionView.reloadData()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   return activeTaskySet.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
    let task = activeTaskySet[indexPath.row]
    
   
    let taskyBlock = UIView()
    cell.addSubview(taskyBlock)
    
    taskyBlock.frame = cell.bounds
    //blockyLabel.text = "<default>"
    
    taskyBlock.layer.borderWidth = 5.0
    taskyBlock.layer.cornerRadius = 25.00
    
    taskyBlock.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    cell.myLabel.text = task.title
    
    taskyBlock.frame.size.height = blockyHeight
    taskyBlock.frame.size.width = blockyWidth
    let taskyLabel = UILabel.init(frame: cell.bounds)
    taskyBlock.addSubview(taskyLabel)
   // let HorizIndent = margin + CGFloat(Double(graphEntry.1) * Double(horizSpacing))
   // let VertIndent = margin + CGFloat(Double(graphEntry.0) * Double(verticalSpacing))
    //cell.frame.origin.x = HorizIndent
    //cell.frame.origin.y = VertIndent

   // let task = graphEntry.2
    
    taskyLabel.text = "\(task.title): \(task.priorityApparent)"
    taskyLabel.textAlignment = .center
    cell.alpha = blockyAlpha
    //cell.taskID = task.taskId
    taskyBlock.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
    cell.backgroundColor = UIColor.clear

    return cell
  }
}





