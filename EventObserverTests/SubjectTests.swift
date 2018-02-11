//
//  SubjectTests.swift
//  EventObserverTests
//
//  Created by Stefano on 03/01/2018.
//  Copyright © 2018 Stefano Pironato. All rights reserved.
//

import XCTest

@testable import EventObserver

enum TestSubjectEvent {
    case eventTest1
    case eventTest2
}

class SubjectTests: XCTestCase {

    var currentExpectation: XCTestExpectation?
    var emittedValues: [String] = []
    var receivedValues: [String] = []
    var emittedEvents: [TestSubjectEvent] = []
    var receivedEvents: [TestSubjectEvent] = []
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        currentExpectation = nil
        emittedValues = []
        receivedValues = []
        emittedEvents = []
        receivedEvents = []
        super.tearDown()
    }
    
    func testGetValueWhenSubscribeClosure() {
        let subject = Subject<String, TestSubjectEvent>("1", subscribeEvent: .eventTest1)
        
        XCTAssertEqual(subject.value, "1")
        
        let exp = expectation(description: "testSignal")
        
        subject.subscribe(dispatcher: .background) {
            (value, event) in
            XCTAssertEqual(value, "1")
            XCTAssertEqual(event, .eventTest1)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testNoValueWhenSubscribeClosure() {
        let subject = Subject<String, TestSubjectEvent>("1")
        
        XCTAssertEqual(subject.value, "1")
        
        let exp = expectation(description: "testSignal")
        
        subject.subscribe {
            (value, event) in
            XCTAssertEqual(value, "2")
            XCTAssertEqual(event, .eventTest2)
            exp.fulfill()
        }
        
        subject.modify(subjectEvent: .eventTest2) {
            _ -> String in
            return "2"
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGetValueWhenSubscribe() {
        
        currentExpectation = expectation(description: "testSignal")
        emittedValues = ["1"]
        emittedEvents = [.eventTest1]
        
        let subject = Subject<String, TestSubjectEvent>(emittedValues[0], subscribeEvent: emittedEvents[0])
        
        XCTAssertEqual(subject.value, emittedValues[0])
        
        subject.subscribe(dispatcher: .background, target: self, handler: SubjectTests.callBackStore)
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedValues,emittedValues)
        XCTAssertEqual(receivedEvents,emittedEvents)
    }
    
    
    func testNoValueWhenSubscribe() {
        
        currentExpectation = expectation(description: "testSignal")
        emittedValues = ["2"]
        emittedEvents = [.eventTest2]
        let subject = Subject<String, TestSubjectEvent>("1")
        
        subject.subscribe(dispatcher: .background, target: self, handler: SubjectTests.callBackStore)
        
        subject.modify(subjectEvent: emittedEvents[0]) {
            _ -> String in
            return self.emittedValues[0]
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedValues,emittedValues)
        XCTAssertEqual(receivedEvents,emittedEvents)
    }
    
    func testSubscribeValuesClosure() {
        emittedValues = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        emittedEvents = [.eventTest1, .eventTest1, .eventTest2, .eventTest2, .eventTest1, .eventTest1, .eventTest2, .eventTest2, .eventTest1, .eventTest1]
        
        let subject = Subject<String, TestSubjectEvent>(emittedValues[0])
        
        let exp = expectation(description: "testSignal")
        
        subject.subscribe(dispatcher: .background) {
            (value, event) in
            self.receivedValues.append(value)
            self.receivedEvents.append(event)
            if self.receivedValues.count == self.emittedValues.count {
                exp.fulfill()
            }
        }
        for (index, value) in emittedValues.enumerated() {
            subject.modify(subjectEvent: emittedEvents[index]) {
                _ -> String in
                return value
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedValues,emittedValues)
        XCTAssertEqual(receivedEvents,emittedEvents)
    }
    
    func testSubscribeValues() {
        emittedValues = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
        emittedEvents = [.eventTest1, .eventTest1, .eventTest2, .eventTest2, .eventTest1, .eventTest1, .eventTest2, .eventTest2, .eventTest1, .eventTest1]
        
        let subject = Subject<String, TestSubjectEvent>(emittedValues[0])
        
        currentExpectation = expectation(description: "testSignal")
        
        subject.subscribe(dispatcher: .background, target: self, handler: SubjectTests  .callBackStore)
        
        for (index, value) in emittedValues.enumerated() {
            subject.modify(subjectEvent: emittedEvents[index]) {
                _ -> String in
                return value
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedValues,emittedValues)
        XCTAssertEqual(receivedEvents,emittedEvents)
    }
    
    func callBackStore(value: String, event: TestSubjectEvent) {
        receivedValues.append(value)
        receivedEvents.append(event)
        if receivedValues.count == emittedValues.count {
            currentExpectation?.fulfill()
        }
    }
}
