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

    private(set) var time = 0.0
    private(set) var requestsCount = 0

    private var writeToLog: ((String) -> ())?

    init(priority: Int, cooldown: Double, bufferInserter: BufferInserter) {
        self.cooldown = cooldown
        self.priority = priority
        self.bufferInserter = bufferInserter
    }

    convenience init(priority: Int, cooldown: Double, bufferInserter: BufferInserter, initialTime: Double) {
        self.init(priority: priority, cooldown: cooldown, bufferInserter: bufferInserter)
        self.time = initialTime
    }

    convenience init(priority: Int, cooldown: Double, bufferInserter: BufferInserter, writeToLog: @escaping ((String) -> ())) {
        self.init(priority: priority, cooldown: cooldown, bufferInserter: bufferInserter)
        self.writeToLog = writeToLog
    }

    convenience init(priority: Int, cooldown: Double, bufferInserter: BufferInserter, initialTime: Double, writeToLog: @escaping ((String) -> ())) {
        self.init(priority: priority, cooldown: cooldown, bufferInserter: bufferInserter)
        self.time = initialTime
        self.writeToLog = writeToLog
    }

    private func generateRequest() {
        requestsCount += 1
        let request = Request(name: String(priority) + "." + String(requestsCount), creatorNumber: priority, creationTime: time)
        bufferInserter.insert(request: request)
    }

    func print() {
        Swift.print("  Generator " + String(priority) + ":")
        Swift.print("    time: " + String(time) + ", req count: " + String(requestsCount) + ", cooldown: " + String(cooldown))
    }
}


extension Generator: SpecialConditioned {

    func getNextSCTime() -> Double {
        return time + cooldown
    }

    func makeStep() {
        generateRequest()
        time += cooldown


        writeToLog?("Generator #" + String(priority)
                        + " generated request #"
                        + String(requestsCount)
                        + " at " + String(time))

    }
}
