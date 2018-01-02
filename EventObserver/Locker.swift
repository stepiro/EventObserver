//
//  Locker.swift
//  EventObserver
//
//  Created by Stefano on 02/01/2018.
//  Copyright © 2018 Stefano Pironato. All rights reserved.
//

import Foundation

internal protocol Lock: class {
    func lock()
    func unlock()
}

internal class Locker {
    
    private var _lock: Lock

    init(lock: Lock) {
        self._lock = lock
        lock.lock()
    }
    
    func relock() {
        _lock.lock()
    }
    
    func unlock() {
        _lock.unlock()
    }
    
    deinit {
        _lock.unlock()
    }
}

extension NSRecursiveLock: Lock {}

internal typealias GenLock = NSRecursiveLock

