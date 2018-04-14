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
  
  var realm: Realm!
  var activeTaskySet: Results<TaskyNode>!
  let blockyAlpha: CGFloat = 0.75
  var blockyHeight: CGFloat = 50
  var blockyWidth: CGFloat = 75
  let layout = UICollectionViewFlowLayout()
  var blockSize: CGSize
  {
    get
    {
      return CGSize.init(width: blockyWidth, height: blockyHeight)
    }
  }

  @IBOutlet weak var priorityCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    layout.itemSize = blockSize
    //layout.estimatedItemSize = CGSize.init(width: 500, height: 500)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    //layout.sectionInset = .init(top: blockyHeight, left: blockyHeight, bottom: blockyWidth, right: blockyWidth)
    
    
    priorityCollectionView.collectionViewLayout = layout

  
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
    let taskyLabel = UILabel.init(frame: cell.bounds)
    let taskyBlock = UIView()
    
    cell.addSubview(taskyBlock)
    taskyBlock.addSubview(taskyLabel)
    
    
    cell.frame.size = blockSize
    cell.alpha = blockyAlpha
    cell.backgroundColor = UIColor.clear
    cell.autoresizesSubviews = true
    
    taskyBlock.frame = cell.bounds
    taskyBlock.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    taskyBlock.layer.borderWidth = 5.0
    taskyBlock.layer.cornerRadius = 25.00
    taskyBlock.backgroundColor = TaskyBlockLibrary.calculateBlockColorFrom(task: task)
    taskyBlock.autoresizesSubviews = true
    
    taskyLabel.frame = taskyBlock.bounds
    taskyLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    taskyLabel.text = "\(task.title): \(task.priorityApparent)"
    taskyLabel.textAlignment = .center
    

    
    return cell
  }
}





