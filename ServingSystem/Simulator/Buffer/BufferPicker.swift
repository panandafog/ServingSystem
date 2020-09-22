//
//  BufferPicker.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

class BufferPicker {

    let buffer: Buffer

    init(buffer: Buffer) {
        self.buffer = buffer
    }

    func pick() -> Request? {

        var res: Request? = nil

        for index in 0...Int(buffer.capacity) - 1 {

            if buffer.queue[index] == nil { continue }

            if (res == nil) ||
                (res!.creatorNumber > buffer.queue[index]!.creatorNumber) ||
                (res!.creatorNumber == buffer.queue[index]!.creatorNumber
                    && res!.creationTime > buffer.queue[index]!.creationTime) {

                res = buffer.queue[index]
            }
        }
        return res
    }
}
