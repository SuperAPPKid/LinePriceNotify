//
//  ContentModelManager.swift
//  client
//
//  Created by zhong on 2018/3/5.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreData
class ContentModelManager: NSObject {
    static let sharedInstance = ContentModelManager()
    typealias ViewModel = (web:String,select:Bool,code:String)
    var data:[ViewModel] = [
        (web:"PChome24h購物",select:false,code:"24hpchome"),
        (web:"Yahoo奇摩購物中心",select:false,code:"ybuy"),
        (web:"PChome線上購物",select:false,code:"pchome"),
        (web:"金石堂網路書店",select:false,code:"kingstone"),
        (web:"博客來",select:false,code:"books"),
        (web:"TAAZE讀冊生活",select:false,code:"taaze"),
        (web:"Yahoo!奇摩拍賣",select:false,code:"ybid"),
        (web:"蝦皮拍賣",select:false,code:"shopee"),
        (web:"露天拍賣",select:false,code:"ruten"),
        (web:"friDay購物",select:false,code:"gohappy"),
        (web:"udn買東西購物中心",select:false,code:"udn"),
        (web:"momo購物網",select:false,code:"momoshop")
    ]
    private override init() {
        super.init()
        self.fetchFromPreferShops()
    }
    func fetchFromPreferShops() {
        guard let preferShops:[String] = UserDefaults.standard.array(forKey: "preferShops") as? [String] else {
            return
        }
        self.data = self.data.map({ (web,select,code) -> (String,Bool,String) in
            for item in preferShops {
                if code == item {
                    return (web,true,code)
                }
            }
            return (web,false,code)
        })
    }
}
