//
//  ComboViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-24.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit
import AppusCircleTimer

enum TimerState
{
  case pause, run
}

class ComboViewController: UIViewController {
  
  //MARK: Outlets
  
  @IBOutlet weak var topLabelOutlet: UILabel!
  @IBOutlet weak var tasksWordOutlet: UILabel!
  @IBOutlet weak var completeWordOutlet: UILabel!
  @IBOutlet weak var wonCountOutlet: UILabel!
  @IBOutlet weak var timerLeftLabel: UILabel!
  @IBOutlet weak var timerRightLabel: UILabel!
  @IBOutlet weak var taskTitleLabel: UILabel!
  @IBOutlet weak var taskDescriptionLabel: UILabel!
  @IBOutlet weak var stepperOutlet: UIStepper!
  
  @IBOutlet weak var mainTimerOutlet: AppusCircleTimer!
  @IBOutlet weak var leftTimerOutlet: AppusCircleTimer!
  @IBOutlet weak var rightTimerOutlet: AppusCircleTimer!
  
  var selectedTask: TaskyNode? = TaskyNodeEditor.sharedInstance.database[0]
  var timerState: TimerState = .pause
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.drawScreen()
    mainTimerOutlet.isBackwards = true
    mainTimerOutlet.totalTime = 600
    stepperOutlet.stepValue = 5
    stepperOutlet.minimumValue = 10
    stepperOutlet.maximumValue = 90
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  fileprivate func drawScreen()
  {
    if let uTask = selectedTask
    {
      taskTitleLabel.text = uTask.title
    }
    
    switch self.timerState
    {
    case .pause:
      self.topLabelOutlet.text = "Configure Your Session"
      self.tasksWordOutlet.isHidden = true
      self.completeWordOutlet.isHidden = true
      self.wonCountOutlet.isHidden = true
    //  self.stepperOutlet.isHidden = false
    case .run:
      self.topLabelOutlet.text = "Complete your Tasks"
      self.tasksWordOutlet.isHidden = false
      self.completeWordOutlet.isHidden = false
      self.wonCountOutlet.isHidden = false
      self.stepperOutlet.isHidden = true
    }
  }
  
  //MARK: Actions
  
  @IBAction func timeStepper(_ sender: Any) {
    let duration = stepperOutlet.value
    mainTimerOutlet.totalTime = duration * 60
    print(duration)
    //let roundedDuration = Int(duration)
    //mainTimerOutlet.
    //durationTimeLabel.text = "\(roundedDuration) min"
  }
  @IBAction func completionBoxButton(_ sender: Any) {
  }
  @IBAction func chooseTaskButton(_ sender: Any) {
  }
  @IBAction func mainTimerTap(_ sender: Any) {
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
