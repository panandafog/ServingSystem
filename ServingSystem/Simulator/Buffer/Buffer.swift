//
//  BufferImpl.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

protocol Buffer: AnyObject {
    var capacity: Int { get }
    var queue: [Request?] { get set }
    var hasRequests: Bool { get }
    
    func print()
}

class BufferImpl: Buffer {

    let capacity: Int
    var queue = [Request?]()
    
    var hasRequests: Bool {
        for index in 1...capacity where queue[Int(index - 1)] != nil {
            return true
        }

        return false
    }

    init(capacity: Int) {
        self.capacity = capacity
        
        queue = .init(repeating: nil, count: capacity)
    }

    func print() {
        Swift.print("  Buffer: ")

        for index in 0...queue.count - 1 {
            Swift.print("    " + String(index) + ": " + String(queue[Int(index)]?.name ?? "null"))
        }
    }
}
