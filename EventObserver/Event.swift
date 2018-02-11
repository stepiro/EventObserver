//
//  Event.swift
//  EventObserver
//
//  Created by Stefano Pironato on 23/12/2017.
//  Copyright © 2017 Stefano Pironato. All rights reserved.
//

public class Event<Element>: EventType {
    
    public init() {}
    
    fileprivate var eventSubscriberContainer: EventSubscriberContainer = EventSubscriberContainer<Element>()
       
    public func emit(_ value: Element) {
        eventSubscriberContainer.emit(value)
    }
    
    @discardableResult
    public func subscribe<TargetObject: AnyObject>(dispatcher: DispatcherType = ImmediateDispatcher.instance,
                                                   target: TargetObject,
                                                   handler: @escaping (TargetObject) -> (Element) -> Void) -> Disposable {
        let eventSubscriberWrapper = EventSubscriberMethodWrapper(dispatcher: dispatcher,
                                                                  target: target,
                                                                  handler: handler,
                                                                  eventSubscriberContainer: eventSubscriberContainer)
        eventSubscriberContainer.addInvocable(eventSubscriberWrapper)
        return eventSubscriberWrapper
    }
    
    @discardableResult
    public func subscribe(dispatcher: DispatcherType = ImmediateDispatcher.instance,
                          handler: @escaping (Element) -> Void) -> Disposable {
        let eventSubscriberWrapper = EventSubscriberClosureWrapper(dispatcher: dispatcher,
                                                                   handler: handler,
                                                                   eventSubscriberContainer: eventSubscriberContainer)
        eventSubscriberContainer.addInvocable(eventSubscriberWrapper)
        return eventSubscriberWrapper
    }
    
    fileprivate func dispose(invocable: Invocable) {
        eventSubscriberContainer.dispose(invocable: invocable)
    }
}

protocol Invocable: class {
    func invoke(_ data: Any)
}

private class EventSubscriberContainer<Element> {

    fileprivate var subscribers: [Invocable] = []
    
    fileprivate func addInvocable(_ invocable: Invocable) {
        subscribers.append(invocable)
    }
    
    func emit(_ value: Element) {
        for subscriber in self.subscribers {
            subscriber.invoke(value)
        }
    }
    
    fileprivate func dispose(invocable: Invocable) {
        subscribers = subscribers.filter { $0 !== invocable }
    }
}

private protocol EventSubscriberWrapper: Invocable, Disposable {
    
    associatedtype Element
    weak var eventSubscriberContainer: EventSubscriberContainer<Element>? { get }
    
    var dispatcher: DispatcherType { get }
    
    func run(_ data: Element) -> Void
}

extension EventSubscriberWrapper {
    
    func dispose() {
        eventSubscriberContainer?.dispose(invocable: self)
    }
    
    func invoke(_ data: Any) {
        if let data = data as? Element {
            dispatcher.execute {
                [weak self] in
                guard let strongSelf = self else { return }
                if let _ = strongSelf.eventSubscriberContainer?.subscribers.filter({ $0 === strongSelf }) {
                    strongSelf.run(data)
                }
            }
        }
    }
}

private class EventSubscriberMethodWrapper<TargetObject: AnyObject, Element> : EventSubscriberWrapper {

    weak var target: TargetObject?
    let handler: (TargetObject) -> (Element) -> Void
    weak var eventSubscriberContainer: EventSubscriberContainer<Element>?
    
    var dispatcher: DispatcherType
    
    init(dispatcher: DispatcherType,
         target: TargetObject?,
         handler: @escaping (TargetObject) -> (Element) -> Void,
         eventSubscriberContainer: EventSubscriberContainer<Element>) {
        self.dispatcher = dispatcher
        self.target = target
        self.handler = handler
        self.eventSubscriberContainer = eventSubscriberContainer
    }
    
    func run(_ data: Element) {
        guard let target = target else {
            dispose()
            return
        }
        handler(target)(data)
    }
}

private class EventSubscriberClosureWrapper<Element>: EventSubscriberWrapper {
    
    let handler: (Element) -> Void
    weak var eventSubscriberContainer: EventSubscriberContainer<Element>?
    
    var dispatcher: DispatcherType
    
    init(dispatcher: DispatcherType,
         handler: @escaping (Element) -> Void,
         eventSubscriberContainer: EventSubscriberContainer<Element>) {
        self.dispatcher = dispatcher
        self.handler = handler
        self.eventSubscriberContainer = eventSubscriberContainer
    }
    
    func run(_ data: Element) {
        handler(data)
    }
}
