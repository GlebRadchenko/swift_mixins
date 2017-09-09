//
//  MultiInherited.swift
//  MultiInheritance
//
//  Created by Gleb Radchenko on 9/9/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

protocol ObjcBridgable {
    var bridge: Any { get }
}
extension ObjcBridgable {
    var bridge: Any {
        return self
    }
}

extension Int: ObjcBridgable {
    var bridge: Any {
        return NSNumber(integerLiteral: self)
    }
}

extension UInt: ObjcBridgable {
    var bridge: Any {
        return NSNumber(value: self)
    }
}

extension String: ObjcBridgable { }

protocol MethodContainer {
    var varArgs: [ObjcBridgable] { get }
    var selector: Selector { get }
}

protocol MultiInherited: NSObjectProtocol {
    static var containerType: MethodContainer.Type { get }
}
