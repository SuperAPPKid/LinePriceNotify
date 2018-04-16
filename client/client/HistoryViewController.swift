//
//  HistoryViewController.swift
//  client
//
//  Created by user37 on 2018/3/20.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

protocol HistoryViewControllerDelegate: NSObjectProtocol {
    func moveToResultVC(with data:[Result])
}

class HistoryViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    let index:Int = 2
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    weak var delegate:HistoryViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.deleteBtn.setBackgroundImage(imageFromColor(color: UIColor.lightGray), for: .highlighted)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        fetchHistoryFromCoreData()
        self.animateTable()
    }
    
    func fetchHistoryFromCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let historyRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "History")
        let timeSort = NSSortDescriptor.init(key: "time", ascending: false)
        historyRequest.sortDescriptors = [timeSort]
        fetchedResultsController = NSFetchedResultsController.init(fetchRequest: historyRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            assertionFailure("Fetch Error")
        }
    }
    
    @IBAction func deleteHistory(_ sender: UIButton) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "History")
        let deleteRequest = NSBatchDeleteRequest.init(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error)
        }
        self.fetchHistoryFromCoreData()
        self.tableView.reloadSections(IndexSet.init(integer: 0), with: .left)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let historyItem:History = fetchedResultsController?.object(at: indexPath) as? History else {
            cell.textLabel?.text = "出錯了!!!!!"
            return cell
        }
        cell.textLabel?.text = historyItem.title
        guard let lprice:Int = Int.init(exactly: historyItem.lprice) else{
            cell.detailTextLabel?.text = "???"
            return cell
        }
        guard let hprice:Int = Int.init(exactly: historyItem.hprice) else{
            cell.detailTextLabel?.text = "???"
            return cell
        }
        cell.detailTextLabel?.text = self.makeMoneyString(of: lprice, placeholder: "無") + " ~ " + self.makeMoneyString(of: hprice, placeholder: "無")
        return cell
    }
    
    func animateTable()  {
        self.tableView.reloadData()
        let cells = self.tableView.visibleCells
        let tableHeight = self.tableView.frame.size.height
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        var index = 0
        for cell in cells {
            UIView.animate(withDuration: 1.75, delay: Double(index) * 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            index += 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let historyItem:History = fetchedResultsController?.object(at: indexPath) as? History else {
            assertionFailure()
            return
        }
        
        SearchResultModelManager.sharedInstance.params = ["title":historyItem.title,
                                                          "shops":historyItem.shops]
        if historyItem.lprice != 0 && historyItem.hprice != 0 {
            SearchResultModelManager.sharedInstance.params!["lowPrice"] = historyItem.lprice
            SearchResultModelManager.sharedInstance.params!["highPrice"] = historyItem.hprice
        }
        if historyItem.lprice == 0 && historyItem.hprice != 0 {
            SearchResultModelManager.sharedInstance.params!["highPrice"] = historyItem.hprice
        }
        if historyItem.lprice != 0 && historyItem.hprice == 0 {
            SearchResultModelManager.sharedInstance.params!["lowPrice"] = historyItem.lprice
        }
        
        MyHUD.setMySearchHUD()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        SVProgressHUD.show()
        IconDownloader.clearDiskAndMemory()
        
        SearchResultModelManager.sharedInstance.getData(page: 1, completionHandler: { [unowned self] (results) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                SVProgressHUD.dismiss()
            }
            self.delegate?.moveToResultVC(with: results)
        }, errorHandler: { [unowned self] (error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                SVProgressHUD.dismiss()
                self.popAlert(with: "找不到資料喔!!", needCancelBtn: false, okHandler: nil)
            }
        })
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
