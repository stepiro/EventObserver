//
//  Dispacher.swift
//  EventObserver
//
//  Created by Stefano Pironato on 22/12/2017.
//  Copyright © 2017 Stefano Pironato. All rights reserved.
//

public enum Dispatcher {
    case immediate
    case main
    case background
    case queue(qos: DispatchQoS, label: String, target: DispatchQueue?)
    
    var get: DispatcherType {
        switch self {
        case .immediate: return ImmediateDispatcher.instance
        case .main: return MainDispatcher.instance
        case .background: return BackgroundDispatcher()
        case .queue(let qos, let label, let target): return QueueDispatcher(qos: qos, label: label, target: target)
        }
    }
}

public final class ImmediateDispatcher: DispatcherType {
    
    public init() {
    }
    
    public static var instance = ImmediateDispatcher()
    
    public func execute(closure: @escaping () -> Void) {
        closure()
    }
}

public final class MainDispatcher: DispatcherType {
    
    private let queue: DispatchQueue
    
    public static var instance = MainDispatcher()
    
    public init() {
        queue = DispatchQueue.main
    }
    
    public func execute(closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            queue.async {
                closure()
            }
        }
    }
}

public class QueueDispatcher: DispatcherType {
    
    private let serialQueue: DispatchQueue
    
    public init(qos: DispatchQoS = .default,
                label: String = "fi.eventobserver.queue",
                target: DispatchQueue? = nil) {
        serialQueue = DispatchQueue(label: label,
                                    qos: qos,
                                    attributes: [],
                                    target: target)
    }
    
    public func execute(closure: @escaping () -> Void) {
        serialQueue.async {
            closure()
        }
    }
}

public final class BackgroundDispatcher: QueueDispatcher {
    convenience init() {
        self.init(qos: .background, label: "fi.eventobserver.backgroundqueue")
    }
}
