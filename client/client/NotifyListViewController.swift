//
//  NotifyViewController.swift
//  client
//
//  Created by user37 on 2018/3/7.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import SVProgressHUD

class NotifyListViewController: UITableViewController{
    var notifyList:[Notify]?
    var preferShops:[String]?
    var cellStatusIsOpen:[Bool] = []
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        reachibilityCheck()
        self.tableView.reloadData()
        
        if UserDefaults.standard.value(forKey: "lineToken") == nil {
            let alertVC = UIAlertController.init(title: "登入Line後才能使用本項功能", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "馬上登入", style: .default) { (action) in
                let toVC = self.storyboard?.instantiateViewController(withIdentifier: "LineVerifyViewController") as! LineVerifyViewController
                self.navigationController?.pushViewController(toVC, animated: true)
            }
            let cancelAction = UIAlertAction.init(title: "取消", style: .destructive) { (acrion) in
                self.tabBarController?.selectedIndex = 1
            }
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        if let selfnotifyList = self.notifyList {
            if self.cellStatusIsOpen.isEmpty {
                self.cellStatusIsOpen = Array(repeating: false, count: selfnotifyList.count)
            }
        } else {
            weak var tabbarController = self.tabBarController as? TabBarViewController
            NotifyListModelManager.sharedInstance.fetchData(completionHandler: { [unowned self]
                (notifyList) in
                self.notifyList = notifyList
                self.cellStatusIsOpen = Array(repeating: false, count: notifyList.count)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    tabbarController?.uploadBadge(withNum: self.notifyList?.count)
                }
                }, errorHandler: { [unowned self] (error) in
                    self.popAlert(with: String(error.code), needCancelBtn: false, okHandler: nil)
                    print(error.domain)
            })
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
            [unowned self] (timer) in
            if let visibleCells = self.tableView.visibleCells as? [NotifyListCell] {
                for cell in visibleCells {
                    guard let row = self.tableView.indexPath(for: cell)?.row else {
                        timer.invalidate()
                        return
                    }
                    self.setUpStatus(cell: cell, row: row)
                }
            } else {
                timer.invalidate()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.timer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NotifyListCell else {
            return
        }
        cell.squareView.backgroundColor = #colorLiteral(red: 0.8426245451, green: 0.5737431049, blue: 0.1107387021, alpha: 1)
        guard let toVC = self.storyboard?.instantiateViewController(withIdentifier: "NotifyDetailViewController") as? NotifyDetailViewController else {
            return
        }
        guard let indexPath:IndexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        toVC.index = indexPath.row
        toVC.titleText = self.notifyList?[indexPath.row].title ?? ""
        toVC.lowPrice = self.notifyList?[indexPath.row].lowPrice ?? 0
        toVC.highPrice = self.notifyList?[indexPath.row].highPrice ?? 0
        toVC.preferShops = self.notifyList?[indexPath.row].shops ?? []
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            completion(true)
        }
        action.backgroundColor = .white
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: nil) {
            (action, view, nil)  in
        }
        action.backgroundColor = .darkGray
        action.title = self.notifyList?[indexPath.row].date
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    //    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        let action = UITableViewRowAction(style: .normal, title: nil) { (action, index) in
    //        }
    //        action.backgroundColor = .darkGray
    //        action.title = (self.notifyList?[indexPath.row].date ?? "加入時間不明")
    //        return [action]
    //    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifyList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NotifyListCell = self.tableView.dequeueReusableCell(withIdentifier: "NotifyListCell", for: indexPath) as! NotifyListCell
        cell.squareView.backgroundColor = #colorLiteral(red: 1, green: 0.7232803884, blue: 0.04563229033, alpha: 1)
        self.setUpStatus(cell: cell, row: indexPath.row)
        cell.configure(title: notifyList?[indexPath.row].title ?? "",
                       lowPrice: notifyList?[indexPath.row].lowPrice ?? 0,
                       highPrice: notifyList?[indexPath.row].highPrice ?? 0)
        
        cell.changeStatus(isOpen: self.cellStatusIsOpen[indexPath.row], animate: false)
        cell.doSomethingWhenStatusClick = {
            [unowned self] in
            let newStatus = !self.cellStatusIsOpen[indexPath.row]
            cell.changeStatus(isOpen: newStatus, animate: true)
            self.cellStatusIsOpen[indexPath.row] = newStatus
        }
        
        return cell
    }
    
    func setUpStatus(cell:NotifyListCell,row:Int) {
        guard let oldDateString = self.notifyList?[row].date,let periodComponents = getDateComponents(from: oldDateString) else{
            return
        }
        var countString = ""
        if let years = periodComponents.year,let months = periodComponents.month,
            let days = periodComponents.day,let hours = periodComponents.hour,
            let mins = periodComponents.minute,let secs = periodComponents.second {
            if years != 0 {
                countString = "已經找了\(years)年，刪了吧"
                cell.statusButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.9001230736)
                cell.statusButton.layer.borderColor = #colorLiteral(red: 0.806736052, green: 0.1324509382, blue: 0.03714900836, alpha: 1)
            }
            else if months != 0 {
                countString = "已經找了\(months)個月，刪了吧"
                cell.statusButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 0.9001230736)
                cell.statusButton.layer.borderColor = #colorLiteral(red: 0.806736052, green: 0.1324509382, blue: 0.03714900836, alpha: 1)
            }
            else if days != 0 {
                countString = "已經找了\(days * 24 + hours)小時\(String(format: "%02d", mins))分\(String(format: "%02d", secs))秒"
                if days >= 3 {
                    cell.statusButton.backgroundColor = UIColor(red: 255, green: CGFloat(180 - (6 * days)) / 255, blue: 0, alpha: 0.9)
                    cell.statusButton.layer.borderColor = UIColor(red: 150, green: CGFloat(180 - (6 * days)) / 255, blue: 0, alpha: 1).cgColor
                } else {
                    cell.statusButton.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0, alpha: 0.9502889555)
                    cell.statusButton.layer.borderColor = #colorLiteral(red: 0.0135944467, green: 0.4697206286, blue: 0.01800602674, alpha: 1)
                }
            }
            else if hours != 0 {
                countString = "已經找了\(hours)小時\(String(format: "%02d", mins))分\(String(format: "%02d", secs))秒"
                cell.statusButton.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0, alpha: 0.9502889555)
                cell.statusButton.layer.borderColor = #colorLiteral(red: 0.0135944467, green: 0.4697206286, blue: 0.01800602674, alpha: 1)
            }
            else {
                countString = "已經找了\(String(format: "%02d", mins))分\(String(format: "%02d", secs))秒"
                cell.statusButton.backgroundColor = #colorLiteral(red: 0, green: 0.5607843137, blue: 0, alpha: 0.9502889555)
                cell.statusButton.layer.borderColor = #colorLiteral(red: 0.0135944467, green: 0.4697206286, blue: 0.01800602674, alpha: 1)
            }
        } else {
            countString = "無法取得日期"
            cell.statusButton.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
        cell.statusButton.setTitle(countString, for: .selected)
    }
}
