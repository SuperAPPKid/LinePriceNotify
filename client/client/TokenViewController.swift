//
//  TokenViewController.swift
//  client
//
//  Created by zhong on 2018/4/11.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import SVProgressHUD
class TokenViewController: UIViewController {

    @IBOutlet weak var tokenLabel: UILabel!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var tokenInputField: UITextField!
    @IBOutlet weak var sharedButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var tokenButton: UIButton!
    @IBOutlet weak var jumpView: UIView!
    var isOpen = false

    override func viewDidLoad() {
        super.viewDidLoad()
        sharedButton.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
        copyButton.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
        tokenButton.setBackgroundImage(imageFromColor(color: UIColor(red: 50.0/255.0, green: 84.0/255.0, blue: 112.0/255.0, alpha: 1.0)), for: .highlighted)
        sharedButton.setBackgroundImage(imageFromColor(color: #colorLiteral(red: 0.8526440859, green: 0.6163793802, blue: 0.07058323175, alpha: 1)), for: .disabled)
        copyButton.setBackgroundImage(imageFromColor(color: #colorLiteral(red: 0.8526440859, green: 0.6163793802, blue: 0.07058323175, alpha: 1)), for: .disabled)
        tokenButton.setBackgroundImage(imageFromColor(color: #colorLiteral(red: 0.8526440859, green: 0.6163793802, blue: 0.07058323175, alpha: 1)), for: .disabled)
        
        if let tokenString = UserDefaults.standard.value(forKey: "lineToken") as? String {
            tokenLabel.text = tokenString
            sharedButton.isEnabled = true
            copyButton.isEnabled = true
            tokenButton.isEnabled = false
            tokenButton.setTitle("已經登入", for: .disabled)
        } else {
            tokenLabel.text = "您尚未登入，無法取得Token"
            sharedButton.isEnabled = false
            copyButton.isEnabled = false
            tokenButton.isEnabled = true
        }
        
        if let pasteboardStr = UIPasteboard.general.string, pasteboardStr == tokenLabel.text {
            copyButton.isEnabled = false
            copyButton.setTitle("已複製", for: .disabled)
        }
        
        tokenInputField.isHidden = true
        
        sharedButton.layer.cornerRadius = 5
        copyButton.layer.cornerRadius = 5
        tokenButton.layer.cornerRadius = 5
        
        jumpView.layer.cornerRadius = 20
        jumpView.isUserInteractionEnabled = true
        jumpView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearView)))
    }
    
    @objc func clearView(sender:UITapGestureRecognizer?) {
        tokenInputField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tokenInputField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func copyClick(_ sender: UIButton) {
            UIPasteboard.general.string = tokenLabel.text
            copyButton.isEnabled = false
            copyButton.setTitle("已複製", for: .disabled)
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        let firstActivityItem = tokenLabel.text
        let image = UIImage(named: "launch")
        let activityVC = UIActivityViewController(activityItems: [firstActivityItem ?? "??????????",image!], applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.saveToCameraRoll,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func tokenClick(_ sender: UIButton) {
        if !isOpen {
            UIView.animate(withDuration: 0.5, animations: {
                self.viewHeight.constant = 235
                self.view.layoutIfNeeded()
            }) { (nil) in
                self.tokenInputField.isHidden = false
                self.tokenButton.setTitle("登入", for: .normal)
            }
            isOpen = !isOpen
        } else {
            tokenInputField.resignFirstResponder()
            MyHUD.setMySearchHUD()
            SVProgressHUD.show()
            guard let notVerifyString = self.tokenInputField.text else {
                return
            }
            NotifyListModelManager.sharedInstance.verifyToken(token: notVerifyString, completionHandler: {
                [unowned self] in
                UserDefaults.standard.set(notVerifyString, forKey: "lineToken")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    MyHUD.setMyResultHUD()
                    SVProgressHUD.showSuccess(withStatus: "登入成功")
                    self.tokenInputField.resignFirstResponder()
                    self.dismiss(animated: true, completion: nil)
                }
            }) {
                [unowned self] (error) in
                SVProgressHUD.dismiss()
                self.popAlert(with: "\(error.domain)", needCancelBtn: false, okHandler: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        print("token destroy")
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
