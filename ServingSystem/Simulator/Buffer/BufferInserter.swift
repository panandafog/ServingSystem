//
//  BufferInserter.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

class BufferInserter {

    let buffer: Buffer

    private(set) var bin = [[Request]]()

    init(buffer: Buffer, generatorsCount: UInt) {
        self.buffer = buffer

        for _ in 1...generatorsCount {
            bin.append([Request]())
        }
    }

    func insert(request: Request) {

        let ind = buffer.queue.firstIndex(of: nil)

        if ind != nil {
            buffer.queue[ind!] = request
        } else {
            bin[request.creatorNumber - 1].append(request)
        }
    }
}
