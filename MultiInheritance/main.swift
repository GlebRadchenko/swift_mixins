 //
 //  main.swift
 //  MultiInheritance
 //
 //  Created by Gleb Radchenko on 9/9/17.
 //  Copyright © 2017 Gleb Radchenko. All rights reserved.
 //
 
 import Foundation
 
 enum PersonMethods: MethodContainer {
    var varArgs: [ObjcBridgable] {
        switch self {
        case .setName(let newValue):
            return [newValue]
        default:
            return []
        }
    }
    
    var selector: Selector {
        switch self {
        case .talk:
            return #selector(Person.talk)
        case .name:
            return #selector(getter: Person.name)
        case .setName:
            return #selector(setter: Person.name)
        }
    }
    
    case talk
    case name
    case setName(newValue: String)
 }
 
 class Person: NSObject, MultiInherited {
    static var containerType: MethodContainer.Type = PersonMethods.self
    
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
        
        super.init()
    }
    
    func talk() {
        print("Person")
    }
 }
 
 enum MusicianMethods: MethodContainer {
    var varArgs: [ObjcBridgable] {
        switch self {
        case .setExp(let args):
            return [args]
        case .incrementBy(let args):
            return [args]
        default:
            return []
        }
    }
    
    var selector: Selector {
        switch self {
        case .exp:
            return #selector(getter: Musician.experience)
        case .setExp:
            return #selector(setter: Musician.experience)
        case .play:
            return #selector(Musician.play)
        case .incrementBy:
            return #selector(Musician.incrementExp(by:))
        }
    }
    
    case exp
    case setExp(newValue: Int)
    case play
    case incrementBy(value: Int)
 }
 
 class Musician: NSObject, MultiInherited {
    static var containerType: MethodContainer.Type = MusicianMethods.self
    
    var experience: Int
    
    init(exp: Int) {
        self.experience = exp
        super.init()
    }
    
    func play() {
        print("playing music")
    }
    
    func incrementExp(by value: Int) -> Int {
        experience += value
        return experience
    }
 }
 
 class Student: NSObject, MultiInheritable {
    override init() {
        super.init()
    }
    
    func test() {
        perform(PersonMethods.talk)
        perform(MusicianMethods.play)
        perform(PersonMethods.setName(newValue: "ChangedName"))
        print(perform(PersonMethods.name) ?? "nil")
        perform(MusicianMethods.setExp(newValue: 6))
        print(perform(MusicianMethods.exp) ?? "nil")
    }
 }
 
 //Mixing classes
 Student.self + Person.self + Musician.self
 
 let student = Student()
 
 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    student.test()
 }
 
 RunLoop.main.run()
