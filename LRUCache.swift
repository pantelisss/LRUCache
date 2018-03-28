//
//  LRUCache.swift
//  LRUCache
//
//  Created by Pantelis Giazitsis on 28/03/2018.
//

import Foundation

fileprivate class CacheObject: NSObject {
    var object: AnyObject?
    var key: String?
    weak var next: CacheObject?
    weak var previous: CacheObject?
}

class LRUCache: NSObject {
    private let capacity: Int
    private let cache: [String : CacheObject] = [:]
    
    required init(capacity: Int) {
        assert(capacity>1)
        
        self.capacity = capacity
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning(notification:)), name: .UIApplicationDidReceiveMemoryWarning , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: API
    
    func objectFor(key: String) -> AnyObject? {
        guard let cacheObject = self.cache[key] else {return nil}
        
        return cacheObject.object
    }
    
    // MARK: Notifications
    @objc private func didReceiveMemoryWarning(notification: Notification) {
        
    }
    
}
