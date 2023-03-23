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
        var result: Request?
        var resultIndex: Int?

        for index in 0...buffer.capacity - 1 {

            if buffer.queue[index] == nil { continue }

            if (result == nil) ||
                (result!.creatorNumber > buffer.queue[index]!.creatorNumber) ||
                (result!.creatorNumber == buffer.queue[index]!.creatorNumber
                    && result!.creationTime > buffer.queue[index]!.creationTime) {

                result = buffer.queue[index]
                resultIndex = index
            }
        }
        
        if resultIndex != nil {
            buffer.queue[resultIndex!] = nil
        }
        return result
    }
}
