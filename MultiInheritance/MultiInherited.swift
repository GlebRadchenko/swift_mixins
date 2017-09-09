//
//  MultiInherited.swift
//  MultiInheritance
//
//  Created by Gleb Radchenko on 9/9/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

protocol MethodContainer {
    var varArgs: [CVarArg] { get }
    var selector: Selector { get }
}

protocol MultiInherited: NSObjectProtocol {
    static var containerType: MethodContainer.Type { get }
}
