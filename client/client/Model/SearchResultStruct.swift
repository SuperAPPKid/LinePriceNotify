//
//  SearchResultStruc.swift
//  client
//
//  Created by user37 on 2018/3/7.
//  Copyright © 2018年 zhong. All rights reserved.
//

import Foundation

struct SearchResultStruct:Codable {
    var results:[Result]
}
struct Result:Codable {
    var title:String
    var price:Int
    var shop:String
    var shopUrl:String
    var imgUrl:String
}
