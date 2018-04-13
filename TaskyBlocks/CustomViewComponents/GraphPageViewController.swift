//
//  GraphPageViewController.swift
//  TaskyBlocks
//
//  Created by Chris Eloranta on 2018-04-05.
//  Copyright © 2018 Christopher Eloranta. All rights reserved.
//

import UIKit


class GraphPageViewController: UIPageViewController, UIPageViewControllerDataSource {
  
  //MARK: Pageview Methods
  
  private(set) lazy var orderedViewControllers: [UIViewController] = {
    return [HierarchyViewController(), DependencyViewController()]
  }()
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    return nil
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = self
    if let firstViewController = orderedViewControllers.first
    {
      setViewControllers([firstViewController],
                         direction: .forward,
                         animated: true,
                         completion: nil)
    }
  }
  
  func pageViewController(pageViewController: UIPageViewController,
                          viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else
    {
      return nil
    }
    
    let previousIndex = viewControllerIndex - 1
    
    guard previousIndex >= 0 else
    {
      return nil
    }
    
    guard orderedViewControllers.count > previousIndex else
    {
      return nil
    }
    
    return orderedViewControllers[previousIndex]
  }
  
  func pageViewController(pageViewController: UIPageViewController,
                          viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
  {
    guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else
    {
      return nil
    }
    
    let nextIndex = viewControllerIndex + 1
    let orderedViewControllersCount = orderedViewControllers.count
    
    guard orderedViewControllersCount != nextIndex else
    {
      return nil
    }
    
    guard orderedViewControllersCount > nextIndex else
    {
      return nil
    }
    
    return orderedViewControllers[nextIndex]
  }
  // Do any additional setup after loading the view.
  
  override func didReceiveMemoryWarning()
  {
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
