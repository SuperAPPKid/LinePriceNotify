

import UIKit
import SVProgressHUD
extension UIViewController {
    func imageFromColor(color: UIColor) -> UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    func makeMoneyString(of price:Int,placeholder:String) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        if price == 0 {
            return placeholder
        } else {
            return currencyFormatter.string(from: NSNumber.init(value: price)) ?? placeholder
        }
    }
    func popAlert(with title:String,needCancelBtn:Bool,okHandler:((UIAlertAction)->())?) {
        let alertVC = UIAlertController.init(title: title, message: "", preferredStyle: .alert)
        if needCancelBtn {
            let cancelAction = UIAlertAction.init(title: "取消", style: .destructive, handler: nil)
            alertVC.addAction(cancelAction)
        }
        let okAction = UIAlertAction.init(title: "確認", style: .default, handler: okHandler)
        alertVC.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    func makeDateString(date:Date = Date(),format:String = "yyyy/MM/dd HH:mm:ss") -> String {
        let f = DateFormatter()
        f.timeZone = NSTimeZone.local
        f.dateFormat = format
        let dateString = f.string(from: date)
        return dateString
    }
    func getDateComponents(from dateString:String,format:String = "yyyy/MM/dd HH:mm:ss",to date:Date = Date()) -> DateComponents? {
        let f = DateFormatter()
        f.timeZone = NSTimeZone.local
        f.dateFormat = format
        guard let oldDate = f.date(from: dateString) else {
            assertionFailure()
            return nil
        }
        let calandar = Calendar.current
        let components = calandar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: oldDate, to: date)
        return components
    }
    func reachibilityCheck() {
        if Reachability.isConnectedToNetwork() {
            print("YES NETWORK")
        } else {
            print("NO NETWORK")
            MyHUD.setMyResultHUD()
            SVProgressHUD.showError(withStatus: "請開啟您的網路")
            return
        }
    }
}
