//
//  DatePickerVCViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-27.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit

class DatePickerVCViewController: UIViewController {

  @IBOutlet weak var datePickerOutlet: UIDatePicker!
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func datePickerAction(_ sender: UIDatePicker) {
    print(sender.countDownDuration)
    self.dismiss(animated: true, completion: nil)
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
