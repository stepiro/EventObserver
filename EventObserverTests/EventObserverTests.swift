//
//  EventObserverTests.swift
//  EventObserverTests
//
//  Created by Stefano on 29/12/2017.
//  Copyright © 2017 Stefano Pironato. All rights reserved.
//

import XCTest
@testable import EventObserver

struct StructData: Comparable {
    var name: String
    var city: String
    var age: Int
}

func < (lhs: StructData, rhs: StructData) -> Bool {
    return lhs.name < rhs.name
}

func == (lhs: StructData, rhs: StructData) -> Bool {
    return lhs.name == rhs.name &&
        lhs.city == rhs.city &&
        lhs.age == rhs.age
}

class EventObserverTests: XCTestCase {

    var currentExpectation: XCTestExpectation?
    var currentIsMainThread: Bool?
    
    let testStringValue = "this is a string test value"
    let testIntValue: Int = 1234567890
    let testStructValue: StructData = StructData(name: "HelppoChat", city: "Helsinki", age: 20)
    
    var sentString: [String] = []
    var sentInt: [Int] = []
    var sentStructData: [StructData] = []
    var receivedString: [String] = []
    var receivedInt: [Int] = []
    var receivedStructData: [StructData] = []
    let lock = NSRecursiveLock()
    
    var lastValueDispose1 = 0
    var lastValueDispose2 = 0
    
    let myQueue = DispatchQueue(label: "fi.helppochat.testQueue", qos: .utility)
    
    override func setUp() {
        super.setUp()
        currentExpectation = nil
        currentIsMainThread = nil
        sentString = []
        sentInt = []
        receivedString = []
        receivedInt = []
    }
    
    func testDataAndThread<T, U: AnyObject>(event: Event<T>, target: U, handler: @escaping (U) -> (T) -> (), dataArray: [T], isMainThread: Bool) {
        currentExpectation = expectation(description: "testEvent")
        
        let disposable = event.subscribe(dispatcher: isMainThread ? .main : .background, target: target, handler: handler)
        currentIsMainThread = isMainThread
        dataArray.forEach {
            data in
            if  isMainThread  {
                DispatchQueue.global(qos: .background).async {
                    event.emit(data)
                }
            }
            else {
                myQueue.async {
                    event.emit(data)
                }
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        disposable.dispose()
    }
    
    func testDataAndThreadClosure<T>(event: Event<T>, dataArray: [T], isMainThread: Bool, handler: @escaping (T) -> ()) {
        currentExpectation = expectation(description: "testEvent")
        
        let disposable = event.subscribe(dispatcher: isMainThread ? .main : .background, handler: handler)
        currentIsMainThread = isMainThread
        dataArray.forEach {
            data in
            if  isMainThread  {
                DispatchQueue.global(qos: .background).async {
                    event.emit(data)
                }
            }
            else {
                myQueue.async {
                    event.emit(data)
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        disposable.dispose()
    }
    
    func testDataAndThreadClosureOnlyValue<T>(event: Event<T>, dataArray: [T], isMainThread: Bool, handler: @escaping (T) -> Void) {
        currentExpectation = expectation(description: "testEvent")
        
        let disposable = event.subscribe(dispatcher: isMainThread ? .main : .background, handler: handler)
        currentIsMainThread = isMainThread
        dataArray.forEach {
            (value: T) in
            if  isMainThread  {
                DispatchQueue.global(qos: .background).async {
                    event.emit(value)
                }
            }
            else {
                myQueue.async {
                    event.emit(value)
                }
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        disposable.dispose()
    }
    
    func callbackDispose1(value: Int) {
        lastValueDispose1 = value
    }
    
    func callbackDispose2(value: Int) {
        lastValueDispose2 = value
    }
    
    func testTargetDestructed() {
        
        func testWithOrWithoutDispose(dispose: Bool) {
            class TestDestructed {
                
                var exp: XCTestExpectation?
                let dispose: Bool
                var disposable: Disposable?
                
                init(dispose: Bool) {
                    self.dispose = dispose
                }
                
                deinit {
                    if dispose {
                        disposable?.dispose()
                    }
                    exp?.fulfill()
                }
                
                func callback() {
                    exp?.fulfill()
                }
            }
            
            let event = Event<Void>()
            var testDestructed: TestDestructed? = TestDestructed(dispose: dispose)
            testDestructed!.exp = expectation(description: "testEvent")
            event.subscribe(dispatcher: .background, target: testDestructed!, handler: TestDestructed.callback)
            
            event.emit(())
            waitForExpectations(timeout: 1, handler: nil)
            
            testDestructed!.exp = expectation(description: "testDestruct")
            testDestructed = nil
            waitForExpectations(timeout: 1, handler: nil)
            
            event.emit(())
        }
        testWithOrWithoutDispose(dispose: false)
        testWithOrWithoutDispose(dispose: true)
    }
    
    func testTargetDestructedClosure() {
        
        func testWithOrWithoutDispose(dispose: Bool) {
            class TestDestructed {
                
                var exp: XCTestExpectation?
                let dispose: Bool
                var disposable: Disposable?
                
                init(event: Event<Void>, dispose: Bool) {
                    self.dispose = dispose
                    disposable = event.subscribe(dispatcher: .background) {
                        [weak self] _ in
                        guard let stongSelf = self else { return }
                        stongSelf.exp?.fulfill()
                    }
                }
                
                deinit {
                    if dispose {
                        disposable?.dispose()
                    }
                    exp?.fulfill()
                }
                
            }
            
            let event = Event<Void>()
            var testDestructed: TestDestructed? = TestDestructed(event: event, dispose: dispose)
            testDestructed!.exp = expectation(description: "testEvent")
            
            event.emit(())
            waitForExpectations(timeout: 1, handler: nil)
            
            testDestructed!.exp = expectation(description: "testDestruct")
            testDestructed = nil
            waitForExpectations(timeout: 1, handler: nil)
            
            event.emit(())
        }
        testWithOrWithoutDispose(dispose: false)
        testWithOrWithoutDispose(dispose: true)
    }
    
    func testEventInt() {
        
        let event = Event<Int>()
        sentInt = [Int]( repeating: testIntValue, count: 10 )
        testDataAndThread(event: event, target: self, handler: EventObserverTests.callbackTestEventInt, dataArray: sentInt, isMainThread: true)
        testDataAndThread(event: event, target: self, handler: EventObserverTests.callbackTestEventInt, dataArray: sentInt, isMainThread: false)
    }
    
    func testEventIntClosure() {
        
        let event = Event<Int>()
        sentInt = [Int]( repeating: testIntValue, count: 10 )
        testDataAndThreadClosure(event: event, dataArray: sentInt, isMainThread: true) {
            value in
            self.callbackTestEventInt(value: value)
        }
        testDataAndThreadClosure(event: event, dataArray: sentInt, isMainThread: false) {
            value in
            self.callbackTestEventInt(value: value)
        }
    }
    
    func testEventIntClosureWithValue() {
        
        let event = Event<Int>()
        sentInt = [Int]( repeating: testIntValue, count: 10 )
        testDataAndThreadClosureOnlyValue(event: event, dataArray: sentInt, isMainThread: true) {
            (value: Int) in
            self.callbackTestEventInt(value: value)
        }
        testDataAndThreadClosureOnlyValue(event: event, dataArray: sentInt, isMainThread: false) {
            (value: Int) in
            self.callbackTestEventInt(value: value)
        }
    }
    
    func testEventString() {
        let event = Event<String>()
        
        sentString = [String]( repeating: testStringValue, count: 1 )
        testDataAndThread(event: event, target: self, handler: EventObserverTests.callbackTestEventString, dataArray: sentString, isMainThread: true)
        testDataAndThread(event: event, target: self, handler: EventObserverTests.callbackTestEventString, dataArray: sentString, isMainThread: false)
    }
    
    func testEventStringClosure() {
        let event = Event<String>()
        
        sentString = [String]( repeating: testStringValue, count: 10 )
        testDataAndThreadClosure(event: event, dataArray: sentString, isMainThread: true) {
            value in
            self.callbackTestEventString(value: value)
        }
        testDataAndThreadClosure(event: event, dataArray: sentString, isMainThread: false) {
            value in
            self.callbackTestEventString(value: value)
        }
    }
    
    func testEventStructData() {
        let event = Event<StructData>()
        
        sentStructData = [StructData]( repeating: testStructValue, count: 10 )
        testDataAndThread(event: event, target: self, handler: EventObserverTests.callbackTestEventStructData, dataArray: sentStructData, isMainThread: true)
        testDataAndThread(event: event, target: self, handler: EventObserverTests.callbackTestEventStructData, dataArray: sentStructData, isMainThread: false)
    }
    
    func testEventStructDataClosure() {
        let event = Event<StructData>()
        
        sentStructData = [StructData]( repeating: testStructValue, count: 10 )
        testDataAndThreadClosure(event: event, dataArray: sentStructData, isMainThread: true) {
            value in
            self.callbackTestEventStructData(value: value)
        }
        testDataAndThreadClosure(event: event, dataArray: sentStructData, isMainThread: false) {
            value in
            self.callbackTestEventStructData(value: value)
        }
    }
    
    func testDisposeBag() {
        let event = Event<Int>()
        var count = 0
        var bag: DisposableBag? = DisposableBag()
        
        event.subscribe{ _ in count += 1}.disposeBy(bag!)
        event.subscribe{ _ in count += 1}.disposeBy(bag!)
        event.subscribe{ _ in count += 1}.disposeBy(bag!)

        event.emit(0)
        XCTAssertEqual(count, 3)
        
        bag = nil
        event.emit(1)
        XCTAssertEqual(count, 3)
    }
    
    func callbackTestEventString(value: String) {
        XCTAssertEqual(testStringValue, value)
        receivedString.append(value)
        if let currentIsMainThread = self.currentIsMainThread {
            XCTAssertEqual(currentIsMainThread, Thread.isMainThread)
        }
        if sentString.count == receivedString.count {
            currentExpectation?.fulfill()
            XCTAssertEqual(sentString, receivedString)
            receivedString = []
        }
    }
    
    func callbackTestEventInt(value: Int) {
        XCTAssertEqual(testIntValue, value)
        receivedInt.append(value)
        if let currentIsMainThread = self.currentIsMainThread {
            XCTAssertEqual(currentIsMainThread, Thread.isMainThread)
        }
        if sentInt.count == receivedInt.count {
            currentExpectation?.fulfill()
            XCTAssertEqual(sentInt, receivedInt)
            receivedInt = []
        }
    }
    
    func callbackTestEventStructData(value: StructData) {
        XCTAssertEqual(testStructValue, value)
        receivedStructData.append(value)
        if let currentIsMainThread = self.currentIsMainThread {
            XCTAssertEqual(currentIsMainThread, Thread.isMainThread)
        }
        if sentStructData.count == receivedStructData.count {
            currentExpectation?.fulfill()
            XCTAssertEqual(sentStructData, receivedStructData)
            receivedStructData = []
        }
    }
}

