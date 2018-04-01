//
//  LRUHelpers.swift
//  LRUCache
//
//  Created by Pantelis Giazitsis on 02/04/2018.
//

import Foundation

func synchronized(lockObject: Any, closure: () -> ()) {
    objc_sync_enter(lockObject)
    closure()
    objc_sync_exit(lockObject)
}
