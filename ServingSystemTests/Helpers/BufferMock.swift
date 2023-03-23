//
//  BufferMock.swift
//  ServingSystemTests
//
//  Created by Andrey on 23.03.2023.
//

@testable import ServingSystem

class BufferMock: Buffer {
    
    var capacity: Int
    
    var queue: [ServingSystem.Request?]
    
    var hasRequests: Bool {
        for request in queue where (request != nil) { return true }
        return false
    }
    
    init(capacity: Int, queue: [ServingSystem.Request?]? = nil) {
        self.capacity = capacity
        
        if let queue = queue {
            self.queue = queue
        } else {
            self.queue = .init(repeating: nil, count: capacity)
        }
    }
    
    func print() { }
}
