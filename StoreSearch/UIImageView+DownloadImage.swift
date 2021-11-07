//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by user206341 on 11/7/21.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        // 1.
        let session = URLSession.shared
        
        // 2.
        // , completionHandler: <#T##(URL?, URLResponse?, Error?) -> Void#>
        let downloadTask = session.downloadTask(with: url) {
            [weak self]url, response, error in
            if error == nil, let url = url,
                let data = try? Data(contentsOf: url),  // 3.
               let image = UIImage(data: data) {
                // 4.
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        }
        
        // 5.
        downloadTask.resume()
        return downloadTask
    }
}
