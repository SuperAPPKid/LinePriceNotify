//
//  MenuModelManager.swift
//  client
//
//  Created by zhong on 2018/3/5.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit

class MenuModelManager: NSObject {
    typealias ViewModel = (menuTitle: String, select: Bool)
    
    static let sharedInstance = MenuModelManager()
    
    let data: [ViewModel] = [
        (menuTitle: "查詢＆通知", select:true),
        (menuTitle: "查詢結果", select:false),
        (menuTitle: "歷史查詢", select:false)
    ]
}
