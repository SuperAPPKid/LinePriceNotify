//
//  NotifyDetailViewController.swift
//  client
//
//  Created by user37 on 2018/3/7.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class NotifyDetailViewController: UIViewController {
    var preferShops = [String]()
    var titleText: String? = ""
    var lowPrice:Int = 0
    var highPrice:Int = 0
    var index:Int = 0
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = titleText
        self.navigationController?.navigationBar.isHidden = true
        deleteBtn.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
        updateBtn.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
        cancelBtn.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
    }
    
    @IBAction func editTitle(_ sender: UIButton) {
        let alertVC = UIAlertController.init(title: "請輸入商品名", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "確認", style: .default) { (action) in
            self.titleLabel.text = alertVC.textFields?.first?.text
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .destructive, handler: nil)
        alertVC.addTextField {
            $0.keyboardAppearance = UIKeyboardAppearance.dark
            $0.text = self.titleLabel.text }
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func update_click(_ sender: UIButton) {

        if let myTitle = self.titleLabel.text , myTitle != "" {
            
            guard let childVC = self.childViewControllers.first as? ContentViewController else {
                return
            }
            
            let params:[String:Any] = ["token":UserDefaults.standard.string(forKey: "lineToken") ?? "",
                                       "index":self.index,
                                       "title":self.titleLabel.text ?? "",
                                       "lowPrice":childVC.lowPrice,
                                       "highPrice":childVC.highPrice,
                                       "shops":childVC.preferShops,
                                       "date":makeDateString()]
            
            if childVC.lowPrice > childVC.highPrice && childVC.highPrice != 0 {
                self.popAlert(with: "價格範圍有誤", needCancelBtn: false, okHandler: nil)
            } else if childVC.preferShops.count == 0 {
                self.popAlert(with: "請選擇要搜尋的店家", needCancelBtn: false, okHandler: nil)
            } else{
                weak var firstVC = (self.parent as? NavigationController)?.viewControllers.first as? NotifyListViewController
                self.setupBeforeDoSomething()
                NotifyListModelManager.sharedInstance.update(params: params, completionHandler: {
                    [unowned self] in
                    firstVC?.notifyList = nil
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        MyHUD.setMyResultHUD()
                        SVProgressHUD.showSuccess(withStatus: "更新成功")
                        self.navigationController?.popViewController(animated: true)
                    }
                }) { [unowned self] (error) in
                    firstVC?.notifyList = nil
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.popAlert(with: String(error.code), needCancelBtn: true){ (action) -> () in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        } else {
            let alertVC = UIAlertController.init(title: "請輸入商品名", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "確認", style: .default, handler: {
                [unowned self] (action) in
                self.titleLabel.text = alertVC.textFields?.first?.text
            })
            let cancelAction = UIAlertAction.init(title: "取消", style: .destructive, handler: nil)
            alertVC.addTextField(configurationHandler: { (textField) in
                textField.keyboardAppearance = UIKeyboardAppearance.alert
            })
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func delete_click(_ sender: UIButton) {
        let params:[String:Any] = [
            "token":UserDefaults.standard.string(forKey: "lineToken") ?? "",
            "index":self.index]
        weak var firstVC = (self.parent as? NavigationController)?.viewControllers.first as? NotifyListViewController
        self.setupBeforeDoSomething()
        NotifyListModelManager.sharedInstance.delete(params: params, completionHandler: {
            [unowned self] in
            firstVC?.notifyList = nil
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                MyHUD.setMyResultHUD()
                SVProgressHUD.showSuccess(withStatus: "刪除成功")
                self.navigationController?.popViewController(animated: true)
            }
        }) { (error) in
            firstVC?.notifyList = nil
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.popAlert(with: String(error.code), needCancelBtn: true){ (action) -> () in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
    }
    @IBAction func cancel_click(_ sender: UIButton) {
        NotifyListModelManager.sharedInstance.cancelDownload()
        self.navigationController?.popViewController(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBeforeDoSomething() {
        MyHUD.setMySearchHUD()
        SVProgressHUD.show()
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ContentViewController {
            vc.lowPrice = self.lowPrice
            vc.highPrice = self.highPrice
            vc.preferShops = self.preferShops
        }
    }
    
    deinit {
        print("destroy detail")
    }

}
