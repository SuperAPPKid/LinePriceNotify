//
//  MyHUD.swift
//  client
//
//  Created by zhong on 2018/3/27.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import SVProgressHUD
class MyHUD:NSObject{
    static func setMySearchHUD () {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setMinimumSize(CGSize.init(width: 80, height: 80))
        SVProgressHUD.setCornerRadius(15)
        SVProgressHUD.setRingThickness(5)
    }
    static func setMyResultHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setCornerRadius(15)
    }
    static func setMyLoadingHUD() {
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setMinimumSize(CGSize.init(width: 80, height: 80))
        SVProgressHUD.setCornerRadius(40)
        SVProgressHUD.setRingThickness(5)
    }
}
