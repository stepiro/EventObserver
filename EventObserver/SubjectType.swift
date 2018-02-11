//
//  SubjectType.swift
//  EventObserver
//
//  Created by Stefano on 02/01/2018.
//  Copyright © 2018 Stefano Pironato. All rights reserved.
//

public protocol SubjectType: class, EventSubscribeType {
    associatedtype ValueElement
    associatedtype SubjectEvent
    
    var value: ValueElement { get }
  
    func modify(subjectEvent: SubjectEvent?,
                handler: @escaping (ValueElement) -> ValueElement) -> ValueElement
    func modify(subjectEvent: SubjectEvent?,
                handler: @escaping ((inout ValueElement) -> () -> Void)) -> ValueElement
    
    func modify<ParA>(subjectEvent: SubjectEvent?,
                      handler: @escaping ((inout ValueElement) -> (ParA) -> Void),
                      _ parA: ParA) -> ValueElement
    
    func modify<ParA, ParB>(subjectEvent: SubjectEvent?,
                            handler: @escaping ((inout ValueElement) -> (ParA, ParB) -> Void),
                            _ parA: ParA,
                            _ parB: ParB) -> ValueElement
    
    func modify<ParA, ParB, ParC>(subjectEvent: SubjectEvent?,
                                  handler: @escaping ((inout ValueElement) -> (ParA, ParB, ParC) -> Void),
                                  _ parA: ParA,
                                  _ parB: ParB,
                                  _ parC: ParC) -> ValueElement
}

extension SubjectType {
    
    @discardableResult
    func modify(handler: @escaping (ValueElement) -> ValueElement) -> ValueElement {
        return modify(subjectEvent: nil, handler: handler)
    }

    @discardableResult
    func modify(handler: @escaping ((inout ValueElement) -> () -> Void)) -> ValueElement {
        return modify(subjectEvent: nil, handler: handler)
    }
    
    @discardableResult
    func modify<ParA>(handler: @escaping ((inout ValueElement) -> (ParA) -> Void),
                           _ parA: ParA) -> ValueElement {
        return modify(subjectEvent: nil, handler: handler, parA)
    }
    
    @discardableResult
    func modify<ParA, ParB>(handler: @escaping ((inout ValueElement) -> (ParA, ParB) -> Void),
                                 _ parA: ParA,
                                 _ parB: ParB) -> ValueElement {
        return modify(subjectEvent: nil, handler: handler, parA, parB)
    }
    
    @discardableResult
    func modify<ParA, ParB, ParC>(handler: @escaping ((inout ValueElement) -> (ParA, ParB, ParC) -> Void),
                                       _ parA: ParA,
                                       _ parB: ParB,
                                       _ parC: ParC) -> ValueElement {
        return modify(subjectEvent: nil, handler: handler, parA, parB, parC)
    }
}
