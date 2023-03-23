//
//  BufferInserterImpl.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

protocol BufferInserter {
    var rejectedRequests: [[Request]] { get }
    
    func insert(request: Request)
    func getRejectedRequestsAmount() -> Int
    func getRejectedRequestsAmount(creatorNumber: Int) -> Int
}

class BufferInserterImpl: BufferInserter {

    let buffer: Buffer

    private(set) var rejectedRequests = [[Request]]()

    private var writeToLog: ((String) -> Void)?

    init(buffer: Buffer, generatorsCount: Int) {
        self.buffer = buffer

        for _ in 1...generatorsCount {
            rejectedRequests.append([Request]())
        }
    }

    convenience init(buffer: Buffer, generatorsCount: Int, writeToLog: @escaping ((String) -> Void)) {
        self.init(buffer: buffer, generatorsCount: generatorsCount)
        self.writeToLog = writeToLog
    }

    func insert(request: Request) {
        let ind = buffer.queue.firstIndex(of: nil)

        guard let nNind = ind else {
            rejectedRequests[request.creatorNumber - 1].append(request)
            writeToLog?("Send reject to request #" + String(request.name))
            return
        }

        buffer.queue[nNind] = request
        writeToLog?("Inserted request #" + String(request.name) + "at buffer to position #" + String(nNind + 1))
    }

    func getRejectedRequestsAmount() -> Int {
        var res = 0
        rejectedRequests.forEach({
            res += $0.count
        })
        return res
    }

    func getRejectedRequestsAmount(creatorNumber: Int) -> Int {
        if creatorNumber < 1 {
            return 0
        }
        return Int(rejectedRequests[Int(creatorNumber) - 1].count)
    }
}
