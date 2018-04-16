

import UIKit
extension UITableView {
    func animateTable()  {
        let cells = self.visibleCells
        let tableHeight = self.frame.size.height
        for cell in cells {
            guard let myCell = cell as? SearchResultCell else {
                return
            }
            myCell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        var index = 0
        for cell in cells {
            guard let myCell = cell as? SearchResultCell else {
                return
            }
            UIView.animate(withDuration: 0.5, delay: Double(index) * 0.05, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
                myCell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
            index += 1
        }
    }
}

