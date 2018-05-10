//
//  GraphViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-05-07.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import RealmSwift

protocol GraphViewLayout
{
  var collectionViewLayoutDelegate: CollectionViewLayoutDelegate! {get set}
}

class GraphViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewLayoutDelegate {

  var dataSource: Results<TaskyNode>!
  var graphViewLayout: GraphViewLayout!
  
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var toolBarOutlet: UIToolbar!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = try! Realm()
      dataSource = TaskyNodeEditor.sharedInstance.database
      if self.graphViewLayout == nil
      {
        self.priorityBarItem(self)
      }
      self.graphViewLayout.collectionViewLayoutDelegate = self
      
      self.toolBarOutlet.isTranslucent = true
    }
  
  fileprivate func refreshGraph()
  {
    let layout = self.graphViewLayout as! UICollectionViewLayout
    self.collectionView.reloadData()
    layout.invalidateLayout()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
  {
    return dataSource.count
  }
  
  

 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
 {
  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "graphingCell", for: indexPath) as! GraphingCollectionViewCell
  let task = dataSource[indexPath.row]
  cell.setupCellWith(task: task)
  return cell
  }

func numberOfSections(in collectionView: UICollectionView) -> Int
{
  return 1
  }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func datasource() -> [TaskyNode] {
    return Array(dataSource)
  }
  
  
  @IBAction func hierarchyBarItem(_ sender: Any) {
    print("Hierarchy Pressed")
    graphViewLayout = HierarchyGraphViewLayout()
    graphViewLayout.collectionViewLayoutDelegate = self
    collectionView.dataSource = self
     self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)

    refreshGraph()
    
  }

  @IBAction func dependenceBarItem(_ sender: Any) {
    print("Dependence Pressed")
    graphViewLayout = DependenceGraphViewLayout()
    graphViewLayout.collectionViewLayoutDelegate = self
    collectionView.dataSource = self
    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)

    refreshGraph()
  }
  
  @IBAction func priorityBarItem(_ sender: Any) {
    print("Priority Pressed")
    self.graphViewLayout = PriorityGraphViewLayout()
    graphViewLayout.collectionViewLayoutDelegate = self
    collectionView.dataSource = self
    self.collectionView.setCollectionViewLayout(graphViewLayout as! UICollectionViewLayout, animated: true)

    refreshGraph()
  }
  
}
