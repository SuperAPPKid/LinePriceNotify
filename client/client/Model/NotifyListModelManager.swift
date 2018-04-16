//
//  NotifyListModel.swift
//  client
//
//  Created by zhong on 2018/3/9.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import Alamofire
class NotifyListModelManager: NSObject {
    static let sharedInstance = NotifyListModelManager()
//    let url = "http://192.168.43.37:9999/"
    let url = "http://localhost:9999/"
    var request : Alamofire.Request?
    var manager:Alamofire.SessionManager?
   
    private override init() {
        print("born")
        let configure = URLSessionConfiguration.default
        configure.timeoutIntervalForRequest = 8
        configure.timeoutIntervalForResource = 8
        manager = Alamofire.SessionManager(configuration: configure)
    }
    
    func fetchData(completionHandler:@escaping ([Notify])->Void,errorHandler:@escaping (NSError)->()) {
        let postURL = url + "fetch"
        let params:[String:Any] = ["token":UserDefaults.standard.string(forKey: "lineToken") ?? ""]
        self.cancelDownload()
        self.request = manager?.request(postURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON(queue: DispatchQueue.global(), options: .allowFragments) { (response) in
            if let err = response.error as NSError?{
                errorHandler(err as NSError)
                return
            }
            guard let data = response.data else {
                return
            }
            do {
                let notifyList = try JSONDecoder().decode(NotifyListStruct.self, from: data).list
                completionHandler(notifyList)
                return
            } catch {
                errorHandler(error as NSError)
                return
            }
        }
    }
    
    func verifyToken(token:String,completionHandler:@escaping () ->Void,errorHandler:@escaping (NSError)->()) {
        let getURL = url + "verify"
        let params:[String:Any] = ["token":token]
        self.cancelDownload()
        self.request = manager?.request(getURL, method: .get, parameters: params).responseString(queue: DispatchQueue.global(), encoding: .utf8, completionHandler: { (response) in
            if let err = response.error as NSError?{
                errorHandler(err as NSError)
                return
            }
            guard let responseString = response.result.value else {
                return
            }
            if responseString == "OK" {
                completionHandler()
                return
            } else if responseString == "NG" || responseString == "Unicode"{
                errorHandler(NSError.init(domain: "無效的Token", code: 8787, userInfo: nil))
                return
            } else {
                errorHandler(NSError.init(domain: "伺服器出現問題", code: 8787, userInfo: nil))
                return
            }
        })
    }
    
    func add(params:[String:Any],completionHandler:@escaping ()->Void,errorHandler:@escaping (NSError)->()) {
        let postURL = url + "add"
        self.cancelDownload()
        self.request = manager?.request(postURL, method: .post, parameters: params, encoding: JSONEncoding.default).response(queue: DispatchQueue.global()) { (response) in
            if let err = response.error as NSError?{
                errorHandler(err as NSError)
                return
            }
            guard let data = response.data else {
                return
            }
            if let str = String.init(data: data, encoding: .utf8) , str == "OK" {
                completionHandler()
                return
            } else {
                errorHandler(NSError.init(domain: "伺服器出現問題", code: 8787, userInfo: nil))
                return
            }
        }
    }
    
    func update(params:[String:Any],completionHandler:@escaping ()->Void,errorHandler:@escaping (NSError)->()) {
        let postURL = url + "update"
        self.cancelDownload()
        self.request = manager?.request(postURL, method: .post, parameters: params, encoding: JSONEncoding.default).response(queue: DispatchQueue.global()) { (response) in
            if let err = response.error as NSError?{
                errorHandler(err as NSError)
                return
            }
            guard let data = response.data else {
                return
            }
            if let str = String.init(data: data, encoding: .utf8) , str == "OK" {
                completionHandler()
                return
            } else {
                errorHandler(NSError.init(domain: "伺服器出現問題", code: 8787, userInfo: nil))
                return
            }
        }
    }
    
    func delete (params:[String:Any],completionHandler:@escaping ()->Void,errorHandler:@escaping (NSError)->()) {
        let postURL = url + "delete"
        self.cancelDownload()
        self.request = manager?.request(postURL, method: .post, parameters: params, encoding: JSONEncoding.default).response(queue: DispatchQueue.global()) { (response) in
            if let err = response.error as NSError?{
                errorHandler(err as NSError)
                return
            }
            guard let data = response.data else {
                return
            }
            if let str = String.init(data: data, encoding: .utf8) , str == "OK" {
                completionHandler()
                return
            } else {
                errorHandler(NSError.init(domain: "伺服器出現問題", code: 8787, userInfo: nil))
                return
            }
        }
    }
    
    func deleteAll(completionHandler:@escaping ()->Void,errorHandler:@escaping (NSError)->()) {
        let postURL = url + "deleteAll"
        let params:[String:Any] = ["token":UserDefaults.standard.string(forKey: "lineToken") ?? ""]
        self.cancelDownload()
        self.request = manager?.request(postURL, method: .post, parameters: params, encoding: JSONEncoding.default).response(queue: DispatchQueue.global()) { (response) in
            if let err = response.error as NSError?{
                errorHandler(err as NSError)
                return
            }
            guard let data = response.data else {
                return
            }
            if let str = String.init(data: data, encoding: .utf8) , str == "OK" {
                completionHandler()
                return
            } else {
                errorHandler(NSError.init(domain: "伺服器出現問題", code: 8787, userInfo: nil))
                return
            }
        }
    }
    
    func cancelDownload() {
        print("中斷下載")
        self.request?.cancel()
        self.request = nil
    }
    
}
