//
//  Subject.swift
//  EventObserver
//
//  Created by Stefano on 02/01/2018.
//  Copyright © 2018 Stefano Pironato. All rights reserved.
//

import Foundation

public final class Subject<ValueElement, SubjectEvent>: SubjectType {
    
    public typealias Element = (ValueElement, SubjectEvent)
    
    private var lock: NSRecursiveLock
    
    private var _value: ValueElement
    
    private let queue = DispatchQueue(label: "fi.eventhandler.storeobject.\(ValueElement.self)")
    
    private var event: Event<Element>
    
    private let subscribeEvent: SubjectEvent?
    
    public private(set) var value: ValueElement {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set(newValue) {
            lock.lock()
            _value = newValue
            lock.unlock()
        }
    }
    
    public init(_ value: ValueElement, subscribeEvent: SubjectEvent? = nil) {
        self.lock = NSRecursiveLock()
        self._value = value
        self.event = Event<Element>()
        self.subscribeEvent = subscribeEvent
    }
    
    @discardableResult
    public func subscribe<TargetObject: AnyObject>(dispatcher: DispatcherType = ImmediateDispatcher(),
                                                   target: TargetObject,
                                                   handler: @escaping (TargetObject) -> (Element) -> Void) -> Disposable {
        let disposable = event.subscribe(dispatcher: dispatcher, target: target, handler: handler)
        if let emitter = disposable as? Invocable,
           let subscribeEvent = subscribeEvent {
            let element: Element = (_value, subscribeEvent)
            emitter.invoke(element)
        }
        return disposable
    }
    
    @discardableResult
    public func subscribe(dispatcher: DispatcherType = ImmediateDispatcher(),
                          handler: @escaping (Element) -> Void) -> Disposable {
        let disposable = event.subscribe(dispatcher: dispatcher, handler: handler)
        if let emitter = disposable as? Invocable,
           let subscribeEvent = subscribeEvent {
            let element: Element = (_value, subscribeEvent)
            emitter.invoke(element)
        }
        return disposable
    }
    
    private func modifyClosure(subjectEvent: SubjectEvent?,
                               closure: @escaping (inout ValueElement) -> ValueElement) -> ValueElement {
        var newValue: ValueElement! = nil
        queue.sync {
            newValue = self._value
            newValue = closure(&newValue!)
            self._value = newValue
        }
        if let subjectEvent = subjectEvent {
            event.emit((newValue, subjectEvent))
        }
        return newValue
    }
    
    @discardableResult
    public func modify(subjectEvent: SubjectEvent?,
                       handler: @escaping (ValueElement) -> ValueElement) -> ValueElement {
        return modifyClosure(subjectEvent: subjectEvent) {
            (value: inout ValueElement) in
            return handler(value)
        }
    }
    
    @discardableResult
    public func modify(subjectEvent: SubjectEvent?,
                       handler: @escaping ((inout ValueElement) -> () -> Void)) -> ValueElement {
        return modifyClosure(subjectEvent: subjectEvent) {
            (value: inout ValueElement) in
            handler(&value)()
            return value
        }
    }
    
    @discardableResult
    public func modify<ParA>(subjectEvent: SubjectEvent?,
                             handler: @escaping ((inout ValueElement) -> (ParA) -> Void),
                             _ parA: ParA) -> ValueElement {
        return modifyClosure(subjectEvent: subjectEvent) {
            (value: inout ValueElement) in
            handler(&value)(parA)
            return value
        }
    }
    
    @discardableResult
    public func modify<ParA, ParB>(subjectEvent: SubjectEvent?,
                                   handler: @escaping ((inout ValueElement) -> (ParA, ParB) -> Void),
                                   _ parA: ParA,
                                   _ parB: ParB) -> ValueElement {
        return modifyClosure(subjectEvent: subjectEvent) {
            (value: inout ValueElement) in
            handler(&value)(parA, parB)
            return value
        }
    }
    
    @discardableResult
    public func modify<ParA, ParB, ParC>(subjectEvent: SubjectEvent?,
                                         handler: @escaping ((inout ValueElement) -> (ParA, ParB, ParC) -> Void),
                                         _ parA: ParA,
                                         _ parB: ParB,
                                         _ parC: ParC) -> ValueElement {
        return modifyClosure(subjectEvent: subjectEvent) {
            (value: inout ValueElement) in
            handler(&value)(parA, parB, parC)
            return value
        }
    }
}
