//
//  TabBarViewController.swift
//  client
//
//  Created by user37 on 2018/2/27.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import SVProgressHUD
class TabBarViewController: UITabBarController{
    var badgeCount = 0
    var notifyList:[Notify]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UserDefaults.standard.set("AAAAA", forKey: "lineToken") //for test
        self.selectedIndex = 1
        self.tabBar.shadowImage = UIImage()
        self.tabBar.isTranslucent = false
        self.tabBar.unselectedItemTintColor = UIColor.white
        
        
        if UserDefaults.standard.value(forKey: "lineToken") != nil {
             weak var firstVC = (self.viewControllers?.first as? NavigationController)?.topViewController as? NotifyListViewController
            NotifyListModelManager.sharedInstance.fetchData(completionHandler: { [unowned self]
                (notifyList) in
                self.notifyList = notifyList
                firstVC?.notifyList = notifyList
                self.badgeCount = notifyList.count
                DispatchQueue.main.async {
                    self.tabBar.items?.first?.badgeValue = String(self.badgeCount)
                }
            }) { (error) in
                self.popAlert(with: String(error.code), needCancelBtn: false, okHandler: nil)
            }
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadBadge(withNum num: Int?) {
        guard let count = num else {
            self.tabBar.items?.first?.badgeValue = nil
            return
        }
        self.badgeCount = count
        self.tabBar.items?.first?.badgeValue = String(count)
    }
    
    func badgeNum(add num: Int) {
        self.badgeCount += 1
        self.tabBar.items?.first?.badgeValue = String(self.badgeCount)
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
