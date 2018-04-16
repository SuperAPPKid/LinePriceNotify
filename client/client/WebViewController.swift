//
//  WebViewController.swift
//  client
//
//  Created by zhong on 2018/3/10.
//  Copyright © 2018年 zhong. All rights reserved.
//

//不用了
import UIKit
import WebKit
class WebViewController: UIViewController,WKNavigationDelegate {
    var webView:WKWebView!
    var activityIndicator:UIActivityIndicatorView!
    var urlString:String = ""
    var btnBack = UIBarButtonItem()
    override func viewDidLoad() {
        super.viewDidLoad()
        let fullScreenSize = UIScreen.main.bounds.size
        webView = WKWebView.init(frame: CGRect.init(x: 0,
                                                      y: 0,
                                                      width: fullScreenSize.width,
                                                      height: fullScreenSize.height - 64))
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        btnBack = UIBarButtonItem.init(title: "上一頁", style: .plain, target: self, action: #selector(toBack))
        self.navigationItem.rightBarButtonItem = btnBack
        
        activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint.init(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.4)
        self.view.addSubview(activityIndicator)
        guard let url = URL.init(string: urlString) else {
            return
        }
        self.webView.load(URLRequest.init(url: url))
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc
    func toBack() {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("destroy web")
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
