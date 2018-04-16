//
//  MenuViewCell.swift
//  client
//
//  Created by zhong on 2018/3/5.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
class MenuViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var underLineView: UIView!
    func configure(title: String, active: Bool) {
        nameLabel.text = title
        focus(active)
    }
    
    func focus(_ active: Bool) {
        let color = active ? UIColor(red:0.27, green:0.40, blue:0.59, alpha:1.0) : UIColor.lightGray
        nameLabel.textColor = color
        let underLineColor = active ? UIColor(red:0.27, green:0.40, blue:0.59, alpha:1.0) : UIColor.white
        underLineView.backgroundColor = underLineColor
    }
}
