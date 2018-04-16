//
//  LineVerifyViewController.swift
//  client
//
//  Created by zhong on 2018/3/10.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import WebKit
class LineVerifyViewController: UIViewController,WKNavigationDelegate,WKScriptMessageHandler {
    let urlString = "https://notify-bot.line.me/oauth/authorize?"
                  + "response_type=code"
                  + "&client_id=u8q2t2XzFHd6TLHuZ2ejai"
//        + "&redirect_uri=http://192.168.43.37:9999/echo"
        + "&redirect_uri=http://localhost:9999/echo"
                  + "&scope=notify"
                  + "&state=xxxxxxx"//使用者id可以放這裡
    var webView:WKWebView!
    var activityIndicator:UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let fullScreenSize = UIScreen.main.bounds.size
        self.webView = WKWebView.init(frame: CGRect.init(x: 0,
                                                      y: 0,
                                                      width: fullScreenSize.width,
                                                      height: fullScreenSize.height - 113))
        self.webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.center = CGPoint.init(x: fullScreenSize.width * 0.5, y: fullScreenSize.height * 0.4)
        self.view.addSubview(activityIndicator)
        
        self.webView.configuration.userContentController.add(self, name: "success")
        
        guard let url = URL.init(string: urlString) else {
            return
        }
        self.webView.load(URLRequest.init(url: url))
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: "success")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.navigationItem.title = webView.title
        activityIndicator.stopAnimating()
//        self.webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
//                                        completionHandler: { (html: Any?, error: Error?) in
//                                            guard let htmlString = html as? String else {
//                                                return
//                                            }
//                                            print(htmlString)
//        })
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        guard let body = message.body as? Dictionary<String,String> else {
            return
        }
        guard let token = body["token"], token != "None" else {
            let alertVC = UIAlertController.init(title: "無法取得Token", message: "請稍後再重新登錄", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "確定", style: .default) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        UserDefaults.standard.set(token, forKey: "lineToken")
        let alertVC = UIAlertController.init(title: "成功取得Token", message: token, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "確定", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alertVC = UIAlertController.init(title: "無法取得Token", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "確定", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("destroy LINE")
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
