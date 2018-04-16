//
//  PageViewController.swift
//  client
//
//  Created by zhong on 2018/3/8.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController,UIPageViewControllerDataSource {

    lazy var homeVC:SearchHomeViewController? = self.storyboard?.instantiateViewController(withIdentifier: "SearchHomeViewController") as? SearchHomeViewController
    lazy var resultVC:SearchResultViewController? = self.storyboard?.instantiateViewController(withIdentifier: "SearchResultViewController") as? SearchResultViewController
    lazy var historyVC:HistoryViewController? = self.storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        guard let vc = homeVC else{
            return
        }
        self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }

    //Mark: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController as? SearchHomeViewController != nil {
            return nil
        } else if viewController as? SearchResultViewController != nil {
            return homeVC
        } else if viewController as? HistoryViewController != nil {
            return resultVC
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController as? SearchHomeViewController != nil {
            return resultVC
        } else if viewController as? SearchResultViewController != nil {
            return historyVC
        } else if viewController as? HistoryViewController != nil {
            return nil
        } else {
            return nil
        }
    }
    
    //Mark:MenuViewControllerDelegate
    func afterClickMoveVC(to index: Int) {
        var currentIndex = 0
        if self.viewControllers?.first as? SearchHomeViewController != nil {
            currentIndex = 0
        } else if self.viewControllers?.first as? SearchResultViewController != nil {
            currentIndex = 1
        } else if self.viewControllers?.first as? HistoryViewController != nil {
            currentIndex = 2
        } else {
            assertionFailure()
        }
        let direction:UIPageViewControllerNavigationDirection = currentIndex < index ? .forward:.reverse
        
        if index == 0 {
            guard let toVC = homeVC else {
                return
            }
            toVC.needToReloadContent = false
            self.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
        } else if index == 1 {
            guard let toVC = resultVC else {
                return
            }
            self.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
        } else if index == 2 {
            guard let toVC = historyVC else {
                return
            }
            self.setViewControllers([toVC], direction: direction, animated: true, completion: nil)
        } else {
            assertionFailure("OMG")
        }
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
