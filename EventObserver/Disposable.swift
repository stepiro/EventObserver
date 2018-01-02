//
//  Disposable.swift
//  EventObserver
//
//  Created by Stefano Pironato on 22/12/2017.
//  Copyright © 2017 Stefano Pironato. All rights reserved.
//
import Foundation

public protocol Disposable {
    func dispose()
    
    func disposeBy(_ bag: DisposableBag)
}

extension Disposable {
    func disposeBy(_ bag: DisposableBag) {
        bag.add(self)
    }
}

public class DisposableBag {

    private let lock: Lock = GenLock()
    private var disposables: [Disposable] = []
    
    public init() {}
    
    fileprivate func add(_ disposable: Disposable) {
        _ = Locker(lock: lock)
        disposables.append(disposable)
    }
    
    deinit {
        disposables.forEach { (disposable) in
            disposable.dispose()
        }
    }
}
