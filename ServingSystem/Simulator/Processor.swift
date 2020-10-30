//
//  Processor.swift
//  ServingSystem
//
//  Created by panandafog on 22.09.2020.
//

import Foundation

class Processor {

    private let bufferPicker: BufferPicker

    private(set) var number: UInt = 0
    private(set) var time = 0.0
    private(set) var bisyTime = 0.0
    private(set) var cooldown: Double
    private(set) var minCooldown: Double
    private(set) var maxCooldown: Double
    private(set) var requestsCount = 0

    private(set) var request: Request?
    private(set) var completedRequests = [Request]()

    private var writeToLog: ((String) -> Void)?

    init(number: UInt, bufferPicker: BufferPicker, writeToLog: @escaping ((String) -> Void)) {
        self.number = number
        let properties = SimulationProperties.shared.getProcessingProperties(index: Int(number) - 1)
        self.minCooldown = properties.minTime
        self.maxCooldown = properties.maxTime
        self.bufferPicker = bufferPicker
        self.writeToLog = writeToLog
        self.cooldown = SimulationProperties.shared.getProcessingCooldown(processorNumber: number) ?? 1.0
    }

    private func getRequest() {
        request = bufferPicker.pick()
        if request != nil {
            request?.pickTime = self.time
            self.cooldown = SimulationProperties.shared.getProcessingCooldown(processorNumber: number) ?? 1.0
        }
    }

    private func completeRequest() {
        time += cooldown
        bisyTime += cooldown
        requestsCount += 1
        request!.isCompleted = true
        request!.completionTime = time
        completedRequests.append(request!)

        request = nil
    }

    func print() {
        Swift.print("      time: " + String(time) + ", cooldown: " + String(cooldown) + ", req count: " + String(requestsCount))

        let str1 = "      req: " + String(request?.name ?? "null")
        var str2 = ""

        if request != nil {
            str2 = ", creation time: " + String(request!.creationTime)
        }
        Swift.print(str1 + str2)
    }
}

extension Processor: SpecialConditioned {

    func getNextSCTime() -> Double {
        if request != nil {
            return time + cooldown
        }
        return Double.infinity
    }

    func makeStep() {
        guard self.request != nil else { return }

        completeRequest()
        getRequest()

        if request != nil {
            writeToLog?("Processor #" + String(number)
                            + " got request "
                            + String(request?.name ?? "––")
                            + " at " + String(time))
        } else {
            writeToLog?("Processor #" + String(number)
                            + " gone to sleep"
                            + " at " + String(time))
        }
    }

    func makeStep(time: Double) {
        if request != nil {
            return
        }
        self.time = time
        getRequest()

        if request != nil {
            writeToLog?("Processor #" + String(number)
                            + " woke up and got request "
                            + String(request?.name ?? "––")
                            + " at " + String(time))
        }
    }
}
