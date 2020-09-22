//
//  BufferInserter.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

class BufferInserter {

    let buffer: Buffer

    private(set) var bin = [Request]()

    init(buffer: Buffer) {
        self.buffer = buffer
    }

    func insert(request: Request) {

        let ind = buffer.queue.firstIndex(of: nil)

        if ind != nil {
            buffer.queue[ind!] = request
        } else {
            bin.append(request)
        }
    }
}
