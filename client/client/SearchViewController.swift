//
//  SearchViewController.swift
//  client
//
//  Created by zhong on 2018/2/24.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UIPageViewControllerDelegate,MenuViewControllerDelegate,SearchHomeViewControllerDelegate,HistoryViewControllerDelegate
{
    
    var menuViewController: MenuViewController?
    var pageViewController: PageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController?.delegate = self
        pageViewController?.homeVC?.delegate = self
        pageViewController?.historyVC?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    //Mark:SearchHomeViewControllerDelegate
    func moveToResultVC(with data: [Result]) {
        guard let toVC = pageViewController?.resultVC else {
            return
        }
        toVC.searchResult = data
        toVC.needToScrollToTop = true
        toVC.isLastPage = false 
        toVC.currentPage = 1
        
        DispatchQueue.main.async {
            self.menuViewController?.focusCellAt(IndexPath.init(row: 1, section: 0))
            self.pageViewController?.setViewControllers([toVC], direction: .forward, animated: true)
        }
    }
    
    //Mark:SearchHomeViewControllerMenuViewControllerDelegate
    func afterClickMoveVC(to index: Int) {
        pageViewController?.afterClickMoveVC(to: index)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first as? SearchHomeViewController {
            let indexPath = IndexPath.init(row: currentVC.index, section: 0)
            menuViewController?.focusCellAt(indexPath)
        } else if let currentVC = pageViewController.viewControllers?.first as? SearchResultViewController {
            let indexPath = IndexPath.init(row: currentVC.index, section: 0)
            menuViewController?.focusCellAt(indexPath)
        } else if let currentVC = pageViewController.viewControllers?.first as? HistoryViewController {
            let indexPath = IndexPath.init(row: currentVC.index, section: 0)
            menuViewController?.focusCellAt(indexPath)
        }  else {
            assertionFailure("OMG")
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let currentVC = pendingViewControllers.first as? SearchHomeViewController {
            currentVC.needToReloadContent = false
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MenuViewController {
            menuViewController = vc
            menuViewController?.delegate = self
        } else if let vc = segue.destination as? PageViewController {
            pageViewController = vc
        }
    }
    
    deinit {
        fatalError()
    }
    
}
