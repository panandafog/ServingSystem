//
//  BufferInserter.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

class BufferInserter {

    let buffer: Buffer

    private(set) var bin = [[Request]]()

    private var writeToLog: ((String) -> Void)?

    init(buffer: Buffer, generatorsCount: UInt) {
        self.buffer = buffer

        for _ in 1...generatorsCount {
            bin.append([Request]())
        }
    }

    convenience init(buffer: Buffer, generatorsCount: UInt, writeToLog: @escaping ((String) -> Void)) {
        self.init(buffer: buffer, generatorsCount: generatorsCount)
        self.writeToLog = writeToLog
    }

    func insert(request: Request) {
        let ind = buffer.queue.firstIndex(of: nil)

        guard let nNind = ind else {
            bin[request.creatorNumber - 1].append(request)
            writeToLog?("Send reject to request #" + String(request.name))
            return
        }

        buffer.queue[nNind] = request
        writeToLog?("Inserted request #" + String(request.name) + "at buffer to position #" + String(nNind + 1))
    }
}
