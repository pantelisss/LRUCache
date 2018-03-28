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
    
    // MARK: Linked list functionality
    
    private var head: CacheObject?
    private var tail: CacheObject?
    
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
    
    private func listRemoveOlderObject() -> CacheObject? {
        let removedObject: CacheObject? = head;
        head = head?.next;
        
        // Handle the case of empty list
        if head == nil {
            tail = nil
        }
        
        return removedObject
    }
    
    private func listSendObjectToTail(obj: CacheObject) {
        if obj == tail {  // Is already at the end
            return;
        }
        
        listRemoveObject(obj: obj)
        listAddObject(obj: obj)
    }
    
    private func clearList() {
        head = nil
        tail = nil
    }
 
    // MARK: Notifications
    @objc private func didReceiveMemoryWarning(notification: Notification) {
        
    }

}
