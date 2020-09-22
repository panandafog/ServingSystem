//
//  Generator.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

class Generator {

    let cooldown: Double
    let priority: Int

    private let bufferInserter: BufferInserter

    private var time = 0.0
    private var requestsCount = 0

    init(priority: Int, cooldown: Double, bufferInserter: BufferInserter) {
        self.cooldown = cooldown
        self.priority = priority
        self.bufferInserter = bufferInserter
    }

    convenience init(priority: Int, cooldown: Double, bufferInserter: BufferInserter, initialTime: Double) {
        self.init(priority: priority, cooldown: initialTime, bufferInserter: bufferInserter)
        self.time = initialTime
    }

    private func generateRequest() {
        requestsCount += 1
        let request = Request(name: String(priority) + "." + String(requestsCount), creatorNumber: priority, creationTime: time)
        bufferInserter.insert(request: request)
    }
}


extension Generator: SpecialConditioned {

    func getNextSCTime() -> Double {
        return time + cooldown
    }

    func makeStep() {
        generateRequest()
        time += cooldown
    }
}
