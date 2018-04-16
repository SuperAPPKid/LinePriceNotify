//
//  NotifyListStruct.swift
//  client
//
//  Created by user37 on 2018/3/7.
//  Copyright © 2018年 zhong. All rights reserved.
//

import Foundation

struct NotifyListStruct:Codable {
    var list:[Notify]
}
struct Notify:Codable {
    var title:String
    var lowPrice:Int
    var highPrice:Int
    var shops:[String]
    var date:String
}
