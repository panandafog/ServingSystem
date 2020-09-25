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

    func print() {
        Swift.print("  Buffer: ")

        for index in 0...queue.count - 1 {
            Swift.print("    " + String(index) + ": " + String(queue[Int(index)]?.name ?? "null"))
        }
    }

    func hasRequests() -> Bool {

        for index in 1...capacity {
            if queue[Int(index - 1)] != nil {
                return true
            }
        }

        return false
    }
}
