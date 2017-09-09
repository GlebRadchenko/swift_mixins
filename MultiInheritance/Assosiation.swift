//
//  Assosiation.swift
//  MultiInheritance
//
//  Created by Gleb Radchenko on 9/9/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

public final class ObjectAssosiation<T: Any> {
    private let policy: objc_AssociationPolicy
    
    public init(policy: objc_AssociationPolicy) {
        self.policy = policy
    }
    
    public subscript(index: Any) -> T? {
        get {
            return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? T
        }
        
        set {
            objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy)
        }
    }
}
