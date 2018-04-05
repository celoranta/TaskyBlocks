//
//  PomodoroViewController.swift
//  TestOrdinatorGraphics
//
//  Created by Chris Eloranta on 2018-04-03.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class PomodoroViewController: UIViewController {
  @IBOutlet weak var taskPicker: UIPickerView!
  var crucials: [TaskyNode]!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      taskPicker.dataSource = self as? UIPickerViewDataSource
      taskPicker.delegate = self as? UIPickerViewDelegate
       let keeper = TaskyKeeper()
      let crucialsSet = keeper.crucials()
      var crucialsArray: [TaskyNode] = []
      for task in crucialsSet
      {
        crucialsArray.append(task)
      }
      crucials = crucialsArray
    }

  // returns the number of 'columns' to display.
  @available(iOS 2.0, *)
  public func numberOfComponents(in pickerView: UIPickerView) -> Int
  {
    return 1
  }
  
  
  // returns the # of rows in each component..
  @available(iOS 2.0, *)
  public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
  {
    return 1
  }
  
  // returns width of column and height of row for each component.

//  public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
//  {
//
//  }
  
  // these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
  // for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
  // If you return back a different object, the old one will be released. the view will be centered in the row rect

  public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
  {
    return crucials[row].title
  }
  
//  public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
//
//    {
//
//    }
  
  public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    
  }

  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
