//
//  NotifyListCell.swift
//  client
//
//  Created by user37 on 2018/3/7.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit

class NotifyListCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var squareView: UIView!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var statusButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var statusButtonHeight: NSLayoutConstraint!
    
    var isOpen = false
    var doSomethingWhenStatusClick:(()->())?
    
    override func awakeFromNib() {
        squareView.layer.cornerRadius = 10
        squareView.layer.shadowColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        squareView.layer.shadowOffset = .init(width: 3, height: 3)
        squareView.layer.shadowRadius = 1
        squareView.layer.shadowOpacity = 1
    
        statusButton.layer.borderWidth = 2
        self.beforeTransform()
    }
    
    @IBAction func statusClick(_ sender: UIButton) {
        guard let doSomething = doSomethingWhenStatusClick else{
            return
        }
        doSomething()
    }
    
    func changeStatus(isOpen:Bool,animate:Bool) {
        if animate {
            UIView.animate(withDuration: 0.5, animations: {
                if isOpen {
                    self.afterTransform()
                } else {
                    self.beforeTransform()
                    self.statusButton.isSelected = false
                }
                self.contentView.layoutIfNeeded()
            }) { (bool) in
                if isOpen {
                    self.statusButton.isSelected = true
                }
            }
        } else {
            if isOpen {
                self.afterTransform()
                self.statusButton.isSelected = true
            } else {
                self.beforeTransform()
                self.statusButton.isSelected = false
            }
        }
        
    }
    
    func configure (title:String,lowPrice:Int,highPrice:Int) {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        var priceString = ""
        if highPrice <= lowPrice {
            priceString = currencyFormatter.string(from: NSNumber.init(value: lowPrice))! + " ~ "
        } else {
            priceString = currencyFormatter.string(from: NSNumber.init(value: lowPrice))! + " ~ " + currencyFormatter.string(from: NSNumber.init(value: highPrice))!
        }
        titleLabel.text = title
        priceLabel.text = priceString
    }
    
    private func beforeTransform () {
        statusButtonWidth.constant = 40
        statusButtonHeight.constant = 40
        statusButton.layer.cornerRadius = 20
        
    }
    private func afterTransform () {
        statusButtonWidth.constant = contentView.frame.width / 4 * 3
        statusButtonHeight.constant = 28
        statusButton.layer.cornerRadius = 14
    }
}
