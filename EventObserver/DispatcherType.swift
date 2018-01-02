//
//  DispatchererType.swift
//  EventObserver
//
//  Created by Stefano Pironato on 22/12/2017.
//  Copyright © 2017 Stefano Pironato. All rights reserved.
//

public protocol DispatcherType {
    func execute(closure: @escaping () -> Void)
}
