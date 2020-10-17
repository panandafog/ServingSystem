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

    private var writeToLog: ((String) -> Void)?

    init(priority: Int, bufferInserter: BufferInserter, writeToLog: @escaping ((String) -> Void)) {
        self.priority = priority
        self.cooldown = SimulationProperties.shared.getGenerationCooldown(generatorNumber: UInt(priority)) ?? 1.0
        self.bufferInserter = bufferInserter
        self.writeToLog = writeToLog
    }

    private func generateRequest() {
        requestsCount += 1
        let request = Request(name: String(priority) + "." + String(requestsCount), creatorNumber: priority, creationTime: time)
        bufferInserter.insert(request: request)
    }

    func off() {
        time = Double.infinity
    }

    func print() {
        Swift.print("  Generator " + String(priority) + ":")
        Swift.print("    time: " + String(time) + ", req count: " + String(requestsCount) + ", cooldown: " + String(cooldown))
    }
}

extension Generator: SpecialConditioned {

    func getNextSCTime() -> Double {
        time + (SimulationProperties.shared.getGenerationCooldown(generatorNumber: UInt(priority)) ?? 1.0)
    }

    func makeStep() {
        generateRequest()
        time += SimulationProperties.shared.getGenerationCooldown(generatorNumber: UInt(priority)) ?? 1.0

        writeToLog?("Generator #" + String(priority)
                        + " generated request #"
                        + String(requestsCount)
                        + " at " + String(time))

    }
}
