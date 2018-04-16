//
//  SearchHomeViewController.swift
//  client
//
//  Created by user37 on 2018/3/5.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

protocol SearchHomeViewControllerDelegate: NSObjectProtocol {
    func moveToResultVC(with data:[Result])
}

class SearchHomeViewController: UIViewController , UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    let index:Int = 0
    weak var delegate:SearchHomeViewControllerDelegate?
    var needToReloadContent:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor(red:0.27, green:0.40, blue:0.59, alpha:1.0).cgColor
        textField.delegate = self
        
        searchBtn.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
        addBtn.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reachibilityCheck()
    }
    
    @IBAction func addToNotify(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: "lineToken") == nil {
            let alertVC = UIAlertController.init(title: "登入Line後才能使用本項功能", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "馬上登入", style: .default) { (action) in
                let toVC = self.storyboard?.instantiateViewController(withIdentifier: "LineVerifyViewController") as! LineVerifyViewController
                self.navigationController?.pushViewController(toVC, animated: true)
            }
            let cancelAction = UIAlertAction.init(title: "取消", style: .destructive, handler: nil)
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
        
        guard let fromVC = self.childViewControllers.first as? ContentViewController else {
            return
        }
        guard let toVC = self.storyboard?.instantiateViewController(withIdentifier: "AddNotifyViewController") as? AddNotifyViewController else {
            return
        }
        toVC.titleText = self.textField.text
        toVC.lowPrice = fromVC.lowPrice
        toVC.highPrice = fromVC.highPrice
        toVC.preferShops = fromVC.preferShops
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func search(_ sender: UIButton) {
        if let myTitle = self.textField.text , myTitle != "" {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            guard let childVC = self.childViewControllers.first as? ContentViewController else {
                return
            }
            guard let history:History = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as? History else{
                return
            }
            history.time = NSDate()
            history.title = myTitle
            history.hprice = NSNumber.init(value: childVC.highPrice)
            history.lprice = NSNumber.init(value: childVC.lowPrice)
            history.shops = childVC.preferShops
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
            
            
            if childVC.lowPrice > childVC.highPrice && childVC.highPrice != 0 {
                self.popAlert(with: "價格範圍有誤", needCancelBtn: false, okHandler: nil)
            } else if childVC.preferShops.count == 0 {
                self.popAlert(with: "請選擇要搜尋的店家", needCancelBtn: false, okHandler: nil)
            } else{
                SearchResultModelManager.sharedInstance.params = ["title":myTitle,
                                                                  "shops":childVC.preferShops]
                if childVC.lowPrice != 0 && childVC.highPrice != 0 {
                    SearchResultModelManager.sharedInstance.params!["lowPrice"] = childVC.lowPrice
                    SearchResultModelManager.sharedInstance.params!["highPrice"] = childVC.highPrice
                }
                if childVC.lowPrice == 0 && childVC.highPrice != 0 {
                    SearchResultModelManager.sharedInstance.params!["highPrice"] = childVC.highPrice
                }
                if childVC.lowPrice != 0 && childVC.highPrice == 0 {
                    SearchResultModelManager.sharedInstance.params!["lowPrice"] = childVC.lowPrice
                }
                
                MyHUD.setMySearchHUD()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                SVProgressHUD.show()
                IconDownloader.clearDiskAndMemory()
                SearchResultModelManager.sharedInstance.getData(page: 1, completionHandler: { [unowned self] (results) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        SVProgressHUD.dismiss()
                    }
                    self.delegate?.moveToResultVC(with: results)
                }, errorHandler: {[unowned self] (error) in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        SVProgressHUD.dismiss()
                        self.popAlert(with: "找不到資料喔!!", needCancelBtn: false, okHandler: nil)
                    }
                })
            }
        } else {
            let alertVC = UIAlertController.init(title: "請輸入商品名", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "確認", style: .default, handler: { [unowned self](action) in
                self.textField.text = alertVC.textFields?.first?.text
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
    
    
    //Mark - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ContentViewController {
            let preferShops:[String] = ContentModelManager.sharedInstance.data.filter { (web,select,code) -> Bool in select}.map { (web,select,code) -> String in return code}
            vc.preferShops = preferShops
        }
    }
}
