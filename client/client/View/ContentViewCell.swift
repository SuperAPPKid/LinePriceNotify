//
//  ContentViewCell.swift
//  client
//
//  Created by zhong on 2018/3/5.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit

class ContentViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 3
    }
    
    func configure(title: String, active: Bool) {
        nameLabel.text = title
        focusCell(active)
    }
    
    func focusCell(_ active: Bool) {
        let backgroundColor = active ? UIColor(red:0.27, green:0.40, blue:0.59, alpha:0.85) : UIColor(red:0.84, green:0.84, blue:0.84, alpha:0.8)
        let textColor = active ? UIColor(red:1.0, green:0.7, blue:0.1, alpha:1.0) : UIColor.gray
        let BorderColor = active ? UIColor(red:0.27, green:0.40, blue:0.59, alpha:1.0) : UIColor.white
        self.layer.borderColor = BorderColor.cgColor
        self.nameLabel.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}
