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

    private weak var simulator: Simulator?

    init(priority: Int, bufferInserter: BufferInserter, simulator: Simulator?) {
        self.priority = priority
        self.cooldown = SimulationProperties.shared.getGenerationCooldown(generatorNumber: UInt(priority)) 
        self.bufferInserter = bufferInserter
        self.simulator = simulator
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
        time + (SimulationProperties.shared.getGenerationCooldown(generatorNumber: UInt(priority)) )
    }

    func makeStep() {
        generateRequest()
        time += SimulationProperties.shared.getGenerationCooldown(generatorNumber: UInt(priority)) 

        simulator?.writeToLog("Generator #" + String(priority)
                        + " generated request #"
                        + String(requestsCount)
                        + " at " + String(time))

    }
}
