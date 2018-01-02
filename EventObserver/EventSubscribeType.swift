//
//  EventSubscribeType.swift
//  EventObserver
//
//  Created by Stefano Pironato on 22/12/2017.
//  Copyright © 2017 Stefano Pironato. All rights reserved.
//

public protocol EventSubscribeType {
    associatedtype Element
    func subscribe<TargetObject: AnyObject>(dispatcher: DispatcherType,
                                            target: TargetObject,
                                            handler: @escaping (TargetObject) -> (Element) -> Void) -> Disposable
    func subscribe(dispatcher: DispatcherType, handler: @escaping (Element) -> Void) -> Disposable
}

extension EventSubscribeType {
    
    @discardableResult
    public func subscribe<TargetObject: AnyObject>(dispatcher: Dispatcher = .immediate,
                                                   target: TargetObject,
                                                   handler: @escaping (TargetObject) -> (Element) -> Void) -> Disposable {
        return subscribe(dispatcher: dispatcher.get, target: target, handler: handler)
    }
    
    @discardableResult
    public func subscribe(dispatcher: Dispatcher = .immediate,
                          handler: @escaping (Element) -> Void) -> Disposable {
        return subscribe(dispatcher: dispatcher.get, handler: handler)
    }    
}
