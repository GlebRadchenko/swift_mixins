//
//  MultiInheritable.swift
//  MultiInheritance
//
//  Created by Gleb Radchenko on 9/9/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation

@discardableResult func + <L: MultiInheritable, R: MultiInherited> (_ left: L.Type, _ right: R.Type) -> L.Type {
    left.mixin(right)
    return left
}

@discardableResult func + <L: MultiInheritable> (_ left: L.Type, _ right: AnyClass!) -> L.Type {
    left.mixin(right)
    return left
}

protocol MultiInheritable: NSObjectProtocol {
    static func mixin(_ otherClass: MultiInherited.Type)
    static func mixin(_ otherClass: AnyClass)
    
    @discardableResult func perform(_ method: MethodContainer) -> AnyObject!
}

private let allowedContainersAssosiation: ObjectAssosiation<[MethodContainer.Type]> = ObjectAssosiation(policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
private let runtimeInheritedClassesAssosiation: ObjectAssosiation<[AnyClass]> = ObjectAssosiation(policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

extension MultiInheritable {
    fileprivate static var runtimeInheritedClasses: [AnyClass] {
        get { return runtimeInheritedClassesAssosiation[self] ?? [] }
        set { runtimeInheritedClassesAssosiation[self] = newValue }
    }
    
    fileprivate static var allowedContainers: [MethodContainer.Type] {
        get { return allowedContainersAssosiation[self] ?? [] }
        set { allowedContainersAssosiation[self] = newValue }
    }
}

extension MultiInheritable {
    @discardableResult func perform(_ method: MethodContainer) -> AnyObject! {
        
        if responds(to: method.selector) {
            let args = method.varArgs.flatMap { $0.bridge }
            if args.isEmpty {
                return perform(method.selector)?.takeRetainedValue()
            } else if method.varArgs.count == 1 {
                return perform(method.selector, with: args[0])?.takeUnretainedValue()
            } else if method.varArgs.count == 2 {
                return perform(method.selector, with: args[0], with: args[1])?.takeUnretainedValue()
            } else {
                return performVariableArgs(method)
            }
        }
        
        return nil
    }
}

extension MultiInheritable {
    static func mixin(_ otherClass: MultiInherited.Type) {
        print("Mixin: ", otherClass)
        assert(!allowedContainers.contains(where: { $0 == otherClass.containerType }),
               "MultiInheritable object cannot be mixed in with the same class twice")
        allowedContainers.append(otherClass.containerType)
        
        mixin(otherClass as AnyClass)
    }
    
    fileprivate static func mixin(_ otherClass: AnyClass!) {
        guard let other = otherClass else { return }
        
        mixin(other)
    }
    
    static func mixin(_ otherClass: AnyClass) {
        if otherClass == NSObject.self { return }
        
        if runtimeInheritedClasses.contains(where: { $0 == otherClass }) {
            return
        }
        runtimeInheritedClasses.append(otherClass)
        
        mixMethods(self, otherClass)
        mixProperties(self, otherClass)
        mixProtocols(self, otherClass)
        mixMetas(self, otherClass)
        
        mixParent(otherClass)
    }
    
    fileprivate static func mixMethods(_ cls: AnyClass, _ parentCls: AnyClass) {
        var count: UInt32 = 0
        guard var methods = class_copyMethodList(parentCls, &count) else {
            return
        }
        let cMethods = methods
        
        (0..<count).forEach { (i) in
            let method = methods.pointee
            let sel = method_getName(method)
            let imp = method_getImplementation(method)
            let descr = method_getDescription(method).pointee
            let success = class_addMethod(cls, sel, imp, descr.types)
            print("Method ", descr.name, " success: ", success)
            methods += 1
        }
        
        free(cMethods)
    }
    
    fileprivate static func mixProperties(_ cls: AnyClass, _ parentCls: AnyClass) {
        var count: UInt32 = 0
        
        guard var props = class_copyPropertyList(parentCls, &count) else {
            return
        }
        
        let cProps = props
        
        (0..<count).forEach { (i) in
            let prop = props.pointee
            let name = property_getName(prop)
            var attrCount: UInt32 = 0
            let attrList = property_copyAttributeList(prop, &attrCount)
            
            let success = class_addProperty(cls, name, attrList, attrCount)
            free(attrList)
            
            if let name = name {
                print("Property ", String(cString: name), " success: ", success)
            }
            
            props += 1
        }
        
        free(cProps)
    }
    
    fileprivate static func mixProtocols(_ cls: AnyClass, _ parentCls: AnyClass) {
        var count: UInt32 = 0
        
        var protocols = class_copyProtocolList(parentCls, &count)
        
        (0..<count).forEach { (i) in
            let prot = protocols?[Int(i)]
            let success = class_addProtocol(cls, prot)
            
            if let rawName = protocol_getName(prot) {
                print("Protocol ", String(cString: rawName), " success: ", success)
            }
        }
        
        protocols = nil
    }
    
    fileprivate static func mixMetas(_ cls: AnyClass, _ parentCls: AnyClass) {
        guard let parentIsa = object_getClass(parentCls), let isa = object_getClass(cls) else {
            return
        }
        
        mixMethods(isa, parentIsa)
        mixProperties(isa, parentIsa)
        mixProtocols(isa, parentIsa)
    }
    
    fileprivate static func mixParent(_ cls: AnyClass) {
        mixin(class_getSuperclass(cls))
    }
}

//Try to find better solution
extension MultiInheritable {
    fileprivate func performVariableArgs(_ method: MethodContainer) -> AnyObject? {
        typealias A = Any
        let handle: UnsafeMutableRawPointer! = dlopen("/usr/lib/libobjc.A.dylib", RTLD_NOW)
        defer { dlclose(handle) }
        let objc_msgSend_pointer = dlsym(handle, "objc_msgSend")
        
        let args = method.varArgs.flatMap { $0.bridge }
        
        switch args.count {
        case 3:
            let funcType = (@convention(c)(_ class: Any?, _ sel: Selector!, A?,A?,A?) -> Unmanaged<AnyObject>!).self
            let objc_msgSend = unsafeBitCast(objc_msgSend_pointer, to: funcType)
            return objc_msgSend(self, method.selector, args[0], args[1], args[2])?.takeUnretainedValue()
        case 4:
            let funcType = (@convention(c)(_ class: Any?, _ sel: Selector!, A?,A?,A?,A?) -> Unmanaged<AnyObject>!).self
            let objc_msgSend = unsafeBitCast(objc_msgSend_pointer, to: funcType)
            return objc_msgSend(self, method.selector, args[0], args[1], args[2], args[3])?.takeUnretainedValue()
        case 5:
            let funcType = (@convention(c)(_ class: Any?, _ sel: Selector!, A?,A?,A?,A?,A?) -> Unmanaged<AnyObject>!).self
            let objc_msgSend = unsafeBitCast(objc_msgSend_pointer, to: funcType)
            return objc_msgSend(self, method.selector, args[0], args[1], args[2], args[3], args[4])?.takeUnretainedValue()
        case 5:
            let funcType = (@convention(c)(_ class: Any?, _ sel: Selector!, A?,A?,A?,A?,A?,A?) -> Unmanaged<AnyObject>!).self
            let objc_msgSend = unsafeBitCast(objc_msgSend_pointer, to: funcType)
            return objc_msgSend(self, method.selector, args[0], args[1], args[2], args[3], args[4], args[5])?.takeUnretainedValue()
        default:
            debugPrint("Selector: \(method.selector) requires more args, please extend this methos")
            return nil
        }
        
    }
}
