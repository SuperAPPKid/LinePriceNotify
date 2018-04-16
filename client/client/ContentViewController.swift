//
//  ContentViewController.swift
//  client
//
//  Created by zhong on 2018/3/5.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController{    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lowPriceInput: UITextField!
    @IBOutlet weak var highPriceInput: UITextField!
    @IBOutlet weak var allSelectBtn: UIButton!
    var isSelect:Bool = true
    var lowPrice = 0
    var highPrice = 0
    var shops:[(web:String,select:Bool,code:String)] = []
    var preferShops:[String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lowPriceInput.text = self.makeMoneyString(of: self.lowPrice, placeholder: "")
        highPriceInput.text = self.makeMoneyString(of: self.highPrice, placeholder: "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsets.init(top: self.collectionView.frame.height / 15, left: self.collectionView.frame.width / 12, bottom: 10, right: self.collectionView.frame.width / 12)
        
        lowPriceInput.layer.cornerRadius = 5
        highPriceInput.layer.cornerRadius = 5
        lowPriceInput.layer.borderWidth = 2
        highPriceInput.layer.borderWidth = 2
        lowPriceInput.layer.borderColor =  UIColor(red:0.27, green:0.40, blue:0.59, alpha:1.0).cgColor
        highPriceInput.layer.borderColor =  UIColor(red:0.27, green:0.40, blue:0.59, alpha:1.0).cgColor
        
        lowPriceInput.delegate = self
        highPriceInput.delegate = self
        self.addDoneButtonOnKeyboard(textField: lowPriceInput)
        self.addDoneButtonOnKeyboard(textField: highPriceInput)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let parentVC = self.parent as? SearchHomeViewController {
            if parentVC.needToReloadContent {
                if let preferShops = UserDefaults.standard.array(forKey: "preferShops") as? [String] {
                    self.preferShops = preferShops
                }
            } else {
                parentVC.needToReloadContent = true
            }
        }
        
        shops = ContentModelManager.sharedInstance.data.map({ (web,select,code) -> (String,Bool,String) in
            for item in self.preferShops {
                if item == code {
                    return (web,true,code)
                }
            }
            return (web,false,code)
        })
        
        if preferShops.count != 12 {
            isSelect = true
            allSelectBtn.setTitle("全選", for: .normal)
        } else {
            isSelect = false
            allSelectBtn.setTitle("取消", for: .normal)
        }
        
        self.collectionView.reloadData()
    }
    
    @IBAction func allSelect(_ sender: UIButton) {
        allSelectBtn.setTitle(isSelect ? "取消":"全選", for: .normal)
        
        shops = shops.map { (web,select,code) -> (String,Bool,String) in
            if isSelect {
                return (web,true,code)
            } else {
                return (web,false,code)
            }
        }
        
        if isSelect {
            self.preferShops = shops.map({ (web,select,code) -> String in
                return code
            })
        } else {
            preferShops = []
        }
        
        isSelect = !isSelect
        self.collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("destroy content")
    }
}

extension ContentViewController:UITextFieldDelegate {
    func addDoneButtonOnKeyboard(textField:UITextField)
    {
        let doneToolbar: UIToolbar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: 320, height: 60))
        doneToolbar.barStyle = .black
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
        
    }
    @objc
    func doneButtonAction() {
        let lowNum = Int(self.lowPriceInput.text ?? "") ?? self.lowPrice
        let highNum = Int(self.highPriceInput.text ?? "") ?? self.highPrice
        self.lowPrice = lowNum
        self.highPrice = highNum
        self.lowPriceInput.text = self.makeMoneyString(of: lowNum, placeholder: "")
        self.highPriceInput.text = self.makeMoneyString(of: highNum, placeholder: "")
        self.view.endEditing(true)
    }
    @objc
    func keyboardWillShow(notification: NSNotification) {
        self.collectionView.isUserInteractionEnabled = false
    }
    @objc
    func keyboardWillHide(notification: NSNotification) {
        let lowNum = Int(self.lowPriceInput.text ?? "") ?? self.lowPrice
        let highNum = Int(self.highPriceInput.text ?? "") ?? self.highPrice
        self.lowPrice = lowNum
        self.highPrice = highNum
        self.lowPriceInput.text = self.makeMoneyString(of: lowNum, placeholder: "")
        self.highPriceInput.text = self.makeMoneyString(of: highNum, placeholder: "")
        self.view.endEditing(true)
        self.collectionView.isUserInteractionEnabled = true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}
extension ContentViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    //MARK:UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shops.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "content", for: indexPath) as! ContentViewCell
        let data = shops[indexPath.row]
        cell.configure(title: data.web, active: data.select)
        return cell
    }
    //間隔
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    //行距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.collectionView.frame.height / 15
    }
    //cell寬高
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width:max(self.collectionView.frame.width / 2.36, 177)  , height: 40)
    }
    //選取
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row
        if self.shops[index].select {
            preferShops = preferShops.filter(){ $0 != self.shops[index].code }
        } else {
            preferShops.append(shops[index].code)
        }
        self.shops[index].select = !self.shops[index].select
        collectionView.reloadItems(at: [indexPath])
        
        if preferShops.count != 12 {
            isSelect = true
            allSelectBtn.setTitle("全選", for: .normal)
        } else {
            isSelect = false
            allSelectBtn.setTitle("取消", for: .normal)
        }
        
        print(self.preferShops)
    }
    
}
