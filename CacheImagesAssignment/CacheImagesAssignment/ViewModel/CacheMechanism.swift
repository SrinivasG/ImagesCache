//
//  CacheMechanism.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 18/04/24.
//

import Foundation
import UIKit
    
// Handling data race condition with an actor

//Memory cache handled with NSCache
actor MemoryCache {
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    func save(image: UIImage, with thumbnailId: String) {
        imageCache.setObject(image, forKey: thumbnailId as AnyObject)
    }
    
    func retrieve(with thumbnailId: String) -> UIImage? {
        return imageCache.object(forKey: thumbnailId as AnyObject) as? UIImage
    }
}

//Disk cache handled with File Manager. The images stores in application's caches directory
actor DiskCache {
    func save(image: UIImage, with thumbnailId: String) {
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        let fileName = "\(thumbnailId).jpg"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else {
            return
        }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
    }
    
    func retrieve(with thumbnailId: String) -> UIImage? {
        
      let cachesDirectory = FileManager.SearchPathDirectory.cachesDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(cachesDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let fileName = "\(thumbnailId).jpg"
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            if let image = UIImage(contentsOfFile: imageUrl.path) {
                return image
            }
            return nil
        }
        return nil
    }
}
