//
//  SearchCollectionViewController.swift
//  client
//
//  Created by zhong on 2018/3/5.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
protocol MenuViewControllerDelegate: NSObjectProtocol {
    func  afterClickMoveVC(to index: Int)
}
class MenuViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    var data = MenuModelManager.sharedInstance.data
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //MARK:UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MenuModelManager.sharedInstance.data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "title", for: indexPath) as! MenuViewCell
        cell.configure(title: self.data[indexPath.row].menuTitle, active: self.data[indexPath.row].select)
        return cell
    }
    //MARK: UICollectionViewDelegateFlowLayout
    //間隔=0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    //行距=0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    //cell寬高
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width, height: 50)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        focusCellAt(indexPath)
        self.delegate?.afterClickMoveVC(to: indexPath.row)
    }
    
    func focusCellAt(_ indexPath: IndexPath) {
        
        self.data = self.data.map({ (title,select) -> (String,Bool) in
            return (title,false)
        })
        self.data[indexPath.row].select = true
        self.collectionView.reloadData()
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
