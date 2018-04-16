//
//  SearchResultModel.swift
//  client
//
//  Created by zhong on 2018/3/10.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import Alamofire
class SearchResultModelManager: NSObject {
    static let sharedInstance = SearchResultModelManager()
    var request : Alamofire.Request?
    var params:[String:Any]?
    var manager:Alamofire.SessionManager?
    
    override init() {
        print("born")
        let configure = URLSessionConfiguration.default
        configure.timeoutIntervalForRequest = 8
        configure.timeoutIntervalForResource = 8
        manager = Alamofire.SessionManager(configuration: configure)
    }
    
    func getData(page:Int,completionHandler:@escaping ([Result])->Void,errorHandler:@escaping (NSError)->()) {
//        let postURL = "http://192.168.43.37:9999/search"
        let postURL = "http://localhost:9999/search"
        self.params?["page"] = page
        self.cancelDownload()
        self.request = manager?.request(postURL, method: .post, parameters: self.params, encoding: JSONEncoding.default).responseJSON(queue: DispatchQueue.global(), options: .allowFragments, completionHandler:{ (response) in
            if let err = response.error as NSError?{
                switch err.code {
                case NSURLErrorCancelled:
                    return
                default:
                    errorHandler(err as NSError)
                    return
                }
            }
            guard let data = response.data else {
                errorHandler(NSError.init(domain: "problem never happen (maybe)", code: 8787, userInfo: nil))
                return
            }
            do {
                let errorJson :ErrorJsonStruct = try JSONDecoder().decode(ErrorJsonStruct.self, from: data)
                if errorJson.result == "error" {
                    errorHandler(NSError.init(domain: "server has problem", code: 8787, userInfo: nil))
                    return
                }
            } catch {
                print("no error json")
            }
            do {
                let decodeData = try JSONDecoder().decode(SearchResultStruct.self, from: data)
                let results = decodeData.results
                completionHandler(results)
            } catch {
                errorHandler(error as NSError)
                return
            }
        })
        
    }
    
    func cancelDownload() {
        print("中斷下載")
        self.request?.cancel()
        self.request = nil
    }
}
struct ErrorJsonStruct:Codable {
    var result:String
}
