//
//  SearchResultViewController.swift
//  client
//
//  Created by zhong on 2018/3/10.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import SVProgressHUD
import SafariServices
class SearchResultViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let index:Int = 1
    var searchResult:[Result] = [Result]()
    var needToScrollToTop:Bool = false
    var isLastPage:Bool = false
    var btnFirstTimeShow = true
    var currentPage:Int = 0
    @IBOutlet weak var topBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let img = UIImage.init(named: "top")?.withRenderingMode(.alwaysTemplate)
        self.topBtn.setImage(img, for: .normal)
        self.topBtn.tintColor = UIColor.red
        self.topBtn.layer.cornerRadius = 20
        self.topBtn.imageEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10)
        self.topBtn.isHidden = true
    }
    
    @IBAction func toTop(_ sender: UIButton) {
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reachibilityCheck()
        if self.needToScrollToTop {
            self.tableView.tableFooterView?.isHidden = true
            self.topBtn.isHidden = true
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
            self.needToScrollToTop = false
            self.tableView.animateTable()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        cell.imageView?.image = nil
        cell.titleLabel.text = searchResult[indexPath.row].title
        cell.shopLabel.text = searchResult[indexPath.row].shop
        cell.priceLabel.text = self.makeMoneyString(of: searchResult[indexPath.row].price, placeholder: "")
        
        guard let url = URL.init(string: searchResult[indexPath.row].imgUrl) else {
            return cell
        }
        
        IconDownloader.startDownload(cell: cell, url: url, downloadCompletionHandler: nil)
        
        return cell
    }
    
    func animateBtnShow() {
        self.topBtn.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        UIView.animate(withDuration: 0.5) {
            self.topBtn.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        self.performSegue(withIdentifier: "toWeb", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: self.searchResult[indexPath.row].shopUrl) else {
            return
        }
        if #available(iOS 10.0, *) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredBarTintColor = .white
            safariVC.preferredControlTintColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
            self.present(safariVC, animated: true, completion: nil)
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > 20 {
            self.topBtn.isHidden = false
            if btnFirstTimeShow {
                animateBtnShow()
                btnFirstTimeShow = false
            }
        } else {
            self.topBtn.isHidden = true
            btnFirstTimeShow = true
        }
        
        let lastElement = searchResult.count
        if lastElement == indexPath.row + 1 && !self.isLastPage {
            
            self.currentPage += 1
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            MyHUD.setMyLoadingHUD()
            SVProgressHUD.show()
            
            SearchResultModelManager.sharedInstance.getData(page: self.currentPage, completionHandler: { [unowned self] (results) in
                for result in results {
                    self.searchResult.append(result)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    SVProgressHUD.dismiss()
                }
                }, errorHandler: { [unowned self] (error) -> () in
                    self.isLastPage = true
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        SVProgressHUD.dismiss()
                        self.tableView.tableFooterView?.isHidden = false
                        self.tableView.reloadData()
                        //self.popAlert(with: "沒資料了喔!!\(error.code)")
                    }
            })
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let webVC = segue.destination as? WebViewController else {
            return
        }
        guard let indexPath:IndexPath = self.tableView.indexPathForSelectedRow else{
            return
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
        webVC.urlString = self.searchResult[indexPath.row].shopUrl
    }
    
}

