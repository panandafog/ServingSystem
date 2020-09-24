//
//  BufferInserter.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

class BufferInserter {

    let buffer: Buffer

    private(set) var bin = [[Request]]()

    private var writeToLog: ((String) -> ())?

    init(buffer: Buffer, generatorsCount: UInt) {
        self.buffer = buffer

        for _ in 1...generatorsCount {
            bin.append([Request]())
        }
    }

    convenience init(buffer: Buffer, generatorsCount: UInt, writeToLog: @escaping ((String) -> ())) {
        self.init(buffer: buffer, generatorsCount: generatorsCount)
        self.writeToLog = writeToLog
    }

    func insert(request: Request) {

        let ind = buffer.queue.firstIndex(of: nil)

        if ind != nil {
            buffer.queue[ind!] = request
            writeToLog?("Inserted request #" + String(request.name) + "at buffer to position #" + String(ind! + 1))
        } else {
            bin[request.creatorNumber - 1].append(request)
            writeToLog?("Send reject to request #" + String(request.name))
        }
    }
}
