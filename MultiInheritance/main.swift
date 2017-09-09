 //
 //  main.swift
 //  MultiInheritance
 //
 //  Created by Gleb Radchenko on 9/9/17.
 //  Copyright © 2017 Gleb Radchenko. All rights reserved.
 //
 
 import Foundation
 
 enum ParentClassMethodList: MethodContainer {
    var varArgs:  [CVarArg] {
        switch self {
        case .test:
            return []
        case .test1(let args):
            return [args]
        case .test2(let args):
            return [args.msg1, args.msg2, args.msg3]
        case .test3(let args):
            return [args.msg1, args.msg2, args.msg3, args.msg4]
        }
    }
    
    var selector: Selector {
        switch self {
        case .test:
            return #selector(Parent.test0)
        case .test1:
            return #selector(Parent.test1(mseg:))
        case .test2:
            return #selector(Parent.test2(mseg1:mseg2:mseg3:))
        case .test3:
            return #selector(Parent.test3(mseg1:mseg2:mseg3:mseg4:))
        }
    }
    
    case test
    case test1(msg: String)
    case test2(msg1: String, msg2: String, msg3: String)
    case test3(msg1: String, msg2: String, msg3: String, msg4: String)
 }
 
 class Test: NSObject, MultiInheritable { }
 class Parent2: NSObject {
    let test3 = "123"
    let test4: String
    var tes5: String
    
    init(t4: String, t5: String) {
        self.test4 = t4
        self.tes5 = t5
    }
    
    func test0() {
        print("6")
    }
 }
 
 class God: NSObject {
    var test1: String!
    
    func makeVine() {
        print("vine created")
    }
    
    func pray() {
        print("vine created")
    }
    
    static let testStaticVar1: Int = 0
    static var testStaticVar2: Int = 3
    
    static func testStatic() {
        
    }
 }
 
 class Parent: God {
    var test2: String = "Lel"
    
    override func pray() { }
    
    func test0() {
        print("0")
    }
    
    func test1(mseg: String) {
        print("1: ", mseg)
    }
    
    func test2(mseg1: String, mseg2: String, mseg3: String) {
        print("2: ", mseg1 + mseg2 + mseg3)
    }
    
    func test3(mseg1: String, mseg2: String, mseg3: String, mseg4: String) -> AnyObject {
        print("3: ", mseg1 + mseg2 + mseg3 + mseg4)
        return self
    }
 }
 
 Test.self + Parent.self + Parent2.self
 
 let ob: MultiInheritable = Test()
 ob.perform(ParentClassMethodList.test)
 ob.perform(ParentClassMethodList.test1(msg: "m"))
 ob.perform(ParentClassMethodList.test2(msg1: "1", msg2: "2", msg3: "3"))
 let value = ob.perform(ParentClassMethodList.test3(msg1: "1", msg2: "2", msg3: "3", msg4: "4"))
 print(value ?? "No value")
 
 RunLoop.main.run()
