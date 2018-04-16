//
//  OthersViewController.swift
//  
//
//  Created by zhong on 2018/3/16.
//

import UIKit
import StoreKit
import MessageUI
import SVProgressHUD
class OthersViewController: UITableViewController,MFMailComposeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath.init(row: 1, section: 0) {
            self.performSegue(withIdentifier: "toToken", sender: nil)
        } else if indexPath == IndexPath.init(row: 2, section: 0) {
            if (UserDefaults.standard.value(forKey: "lineToken") as? String) != nil {
                logout()
            } else {
             popAlert(with: "您好像還沒登入", needCancelBtn: false, okHandler: nil)
            }
        } else if indexPath == IndexPath.init(row: 0, section: 1) {
            mail()
        } else if indexPath == IndexPath.init(row: 1, section: 1) {
            SKStoreReviewController.requestReview()
        } else {
            print(indexPath)
        }
    }
    
    func logout() {
        
        weak var firstVC = (self.tabBarController?.viewControllers?.first as! NavigationController).topViewController as? NotifyListViewController
        weak var tabBarVC = self.tabBarController as? TabBarViewController
        
        popAlert(with:"您的資料會從伺服器上刪除，真的要登出嗎？", needCancelBtn: true){ (action)->() in
            NotifyListModelManager.sharedInstance.deleteAll(completionHandler: {
                MyHUD.setMyResultHUD()
                SVProgressHUD.showSuccess(withStatus: "登出成功")
            }) { (error) in
                print(String(error.code))
            }
            firstVC?.notifyList = nil
            tabBarVC?.badgeCount = 0
            tabBarVC?.tabBar.items?.first?.badgeValue = "0"
            UserDefaults.standard.set(nil, forKey: "lineToken")
        }
    }
    
    func mail() {
        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        mailController.setSubject("該吃飯了")
        mailController.setToRecipients(["superappkid@gmail.com"])
        mailController.setMessageBody("Hello from Client", isHTML: false)
        
        self.present(mailController, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        }
        if section == 1 {
            return 3
        }
        return 0
    }
    
    
}
