//
//  IconDownloader.swift
//  client
//
//  Created by zhong on 2018/3/23.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import SDWebImage
class IconDownloader: NSObject {
   class func startDownload(cell:SearchResultCell?,url:URL,downloadCompletionHandler:(()->(Void))?) {
        guard let cell = cell else {
            return
        }
        cell.thumbView.sd_setImage(with: url, placeholderImage: nil, options: [.scaleDownLargeImages,.retryFailed]) { (image, error, casheType, url) in
            if let err = error as NSError?{
                print(err)
            }
        }
    }
    class func clearDiskAndMemory() {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk(onCompletion: nil)
    }
}
