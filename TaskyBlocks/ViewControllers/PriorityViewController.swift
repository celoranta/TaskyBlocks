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
  @IBOutlet weak var priorityCollectionView: UICollectionView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
       //   Bundle.main.loadNibNamed("TaskyBlock2", owner: self, options: nil)
      realm = try! Realm()
      activeTaskySet = realm.objects(TaskyNode.self)//.filter(filter)
      
        // Do any additional setup after loading the view.
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
    cell.myLabel.text = activeTaskySet[indexPath.row].title
    cell.backgroundColor = UIColor.red
    return cell
  }
  
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
