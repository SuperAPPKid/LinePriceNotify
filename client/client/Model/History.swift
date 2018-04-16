//
//  History.swift
//  client
//
//  Created by user37 on 2018/3/21.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreData

class History: NSManagedObject {
    @NSManaged var title:String
    @NSManaged var lprice:NSNumber
    @NSManaged var hprice:NSNumber
    @NSManaged var time:NSDate
    @NSManaged var shops:[String]
}
