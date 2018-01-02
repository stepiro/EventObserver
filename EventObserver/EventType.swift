//
//  EventType.swift
//  EventObserver
//
//  Created by Stefano Pironato on 23/12/2017.
//  Copyright © 2017 Stefano Pironato. All rights reserved.
//

import Foundation

public protocol EventType: EventSubscribeType {
    func emit(_ value: Element)
}
