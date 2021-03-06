//
//  LRUCache.swift
//  LRUCache
//
//  Created by Pantelis Giazitsis on 28/03/2018.
//

import Foundation

fileprivate let ENABLE_LOGS: Bool = false

fileprivate class CacheObject: NSObject {
    var object: AnyObject?
    var key: String?
    weak var next: CacheObject?
    weak var previous: CacheObject?
}

class LRUCache: NSObject {
    private let capacity: Int
    private var cache: [String : CacheObject] = [:]
    
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
    
    /// Retrieve the cached object.
    ///
    /// - Parameter key: The requested key
    /// - Returns: The **user's** cached object
    func objectFor(key: String) -> AnyObject? {
#if ENABLE_LOGS
        print("LRUCache: will access key: ", key)
#endif

        guard let cacheObject = self.cache[key] else {return nil}
        
        listSendObjectToTail(obj: cacheObject)
        
#if ENABLE_LOGS
        printList()
#endif

        return cacheObject.object
    }
    
    /// Insert the passed object in cache or update if the key is already reserved.
    ///
    /// - Parameters:
    ///   - object: The object to be cached
    ///   - key: The key
    func setObject(object: AnyObject, forKey key: String) {
#if ENABLE_LOGS
        defer {
            printList()
        }
        print("LRUCache: will set key: ", key);
#endif
        
        synchronized(lockObject: self) {
            if let cacheObject = cache[key] {
                cacheObject.object = object
                
                return
            }
            
            let cacheObject = CacheObject()
            cacheObject.object = object
            cacheObject.key = key
            
            cache[key] = cacheObject
            
            listAddObject(obj: cacheObject)
            
            purgeCacheIfNeeded()
        }
    }
    
    /// Will remove the object cached with the passed key
    ///
    /// - Parameter key: The key
    func removeObjectFor(key: String) {
#if ENABLE_LOGS
        defer {
            printList()
        }
        print("LRUCache: will remove key: ", key);
#endif

        synchronized(lockObject: self) {
            guard let cacheObject = cache[key] else { return }
            listRemoveObject(obj: cacheObject)
            cache.removeValue(forKey: key)
        }
    }
    
    /// Will clear the cache
    func removeAllObjects() {
        cache.removeAll()
        clearList()
    }
    
    // MARK: Linked list functionality
    
    /*
     Tail will keep the last accessed object. So the first object to be removed is the head.
     */

    private var head: CacheObject?
    private var tail: CacheObject?
    
    /// Add the object at the end of the list
    ///
    /// - Parameter obj: The object
    private func listAddObject(obj: CacheObject) {
        if head == nil, tail == nil {    // List is empty
            head = obj
            tail = obj
            return
        }
        
        // Insert the object at the end of list
        tail!.next = obj;
        obj.previous = tail;
        tail = obj;
    }
    
    /// Remove the object from the list
    ///
    /// - Parameter obj: The object
    private func listRemoveObject(obj: CacheObject) {
        if obj == tail { // Object is at the end of list
            tail = obj.previous
        }
        
        if obj == head {  // Object is at the beggining
            head = obj.next
        }
        
        
        obj.previous?.next = obj.next
        obj.next?.previous = obj.previous
        
        obj.next = nil
        obj.previous = nil
    }
    
    /// Remove the object from the top (head) of the list
    ///
    /// - Returns: The removed object
    private func listRemoveOlderObject() -> CacheObject? {
        let removedObject: CacheObject? = head;
        head = head?.next;
        
        // Handle the case of empty list
        if head == nil {
            tail = nil
        }
        
        return removedObject
    }
    
    /// Will send the object to the end of the list
    ///
    /// - Parameter obj: The object
    private func listSendObjectToTail(obj: CacheObject) {
        if obj == tail {  // Is already at the end
            return;
        }
        
        listRemoveObject(obj: obj)
        listAddObject(obj: obj)
    }
    
    /// Reset the list
    private func clearList() {
        head = nil
        tail = nil
    }
 
    /// Helper method to print the entire list
    private func printList() {
        var obj: CacheObject? = head
        
        print("========================")

        while obj != nil {
            print(obj?.key)
            obj = obj?.next
        }
        print("========================")
    }
    
    // MARK: Helpers
    
    /// Checks if there is overcapacity in the cache and removes older object(s)
    private func purgeCacheIfNeeded() {
        let shouldRemoveObject = capacity < cache.count
        
        if shouldRemoveObject {
#if ENABLE_LOGS
            defer {
                printList()
            }
            print("LRUCache: will purge")
#endif

            guard let removedObject = listRemoveOlderObject() else {return}
            
            if let key = removedObject.key {
                cache.removeValue(forKey: key)
            }
        }
        
    }
    
    // MARK: Notifications
    
    @objc private func didReceiveMemoryWarning(notification: Notification) {
#if ENABLE_LOGS
        print("LRUCache: Received Memory warning")
#endif

        removeAllObjects()
    }

}
