//
//  Buffer.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

class Buffer {

    let capacity: UInt
    var queue = [Request?]()

    init(capacity: UInt) {

        self.capacity = capacity

        for _ in 1...capacity {
            queue.append(nil)
        }
    }
}
