//
//  Simulator.swift
//  ServingSystem
//
//  Created by panandafog on 22.09.2020.
//

import Cocoa

class Simulator {

    var generators = [Generator]()
    var processors = [Processor]()

    var buffer: Buffer

    private var bufferPicker: BufferPicker
    private var bufferInserter: BufferInserter

    private(set) var stepsCounter = 0
    private(set) var realisationTime = 0.0
    private(set) var eventLog = ""
    private(set) var isEnabled = false

    init() {
        let properties = SimulationProperties.shared

        buffer = Buffer(capacity: properties.bufferCapacity)
        bufferPicker = BufferPicker(buffer: buffer)
        bufferInserter = BufferInserter(buffer: buffer, generatorsCount: properties.generatorsAmount)

        for index in 1...Int(properties.generatorsAmount) {
            generators.append(Generator(priority: Int(index),
                                        bufferInserter: bufferInserter,
                                        writeToLog: self.writeToLog(_:)))
        }

        for index in 1...properties.processorsAmount {
            processors.append(Processor(number: index,
                                        bufferPicker: bufferPicker,
                                        writeToLog: self.writeToLog(_:)))
        }
    }
    
    init(bufferCapacity: UInt) {
        let properties = SimulationProperties.shared

        buffer = Buffer(capacity: bufferCapacity)
        bufferPicker = BufferPicker(buffer: buffer)
        bufferInserter = BufferInserter(buffer: buffer, generatorsCount: properties.generatorsAmount)

        for index in 1...Int(properties.generatorsAmount) {
            generators.append(Generator(priority: Int(index),
                                        bufferInserter: bufferInserter,
                                        writeToLog: self.writeToLog(_:)))
        }

        for index in 1...properties.processorsAmount {
            processors.append(Processor(number: index,
                                        bufferPicker: bufferPicker,
                                        writeToLog: self.writeToLog(_:)))
        }
    }
    
    init(generatorsAmount: UInt) {
        let properties = SimulationProperties.shared

        buffer = Buffer(capacity: properties.bufferCapacity)
        bufferPicker = BufferPicker(buffer: buffer)
        bufferInserter = BufferInserter(buffer: buffer, generatorsCount: generatorsAmount)

        for index in 1...Int(generatorsAmount) {
            generators.append(Generator(priority: Int(index),
                                        bufferInserter: bufferInserter,
                                        writeToLog: self.writeToLog(_:)))
        }

        for index in 1...properties.processorsAmount {
            processors.append(Processor(number: index,
                                        bufferPicker: bufferPicker,
                                        writeToLog: self.writeToLog(_:)))
        }
    }
    
    init(processorsAmount: UInt) {
        let properties = SimulationProperties.shared

        buffer = Buffer(capacity: properties.bufferCapacity)
        bufferPicker = BufferPicker(buffer: buffer)
        bufferInserter = BufferInserter(buffer: buffer, generatorsCount: properties.generatorsAmount)

        for index in 1...Int(properties.generatorsAmount) {
            generators.append(Generator(priority: Int(index),
                                        bufferInserter: bufferInserter,
                                        writeToLog: self.writeToLog(_:)))
        }

        for index in 1...processorsAmount {
            processors.append(Processor(number: index,
                                        bufferPicker: bufferPicker,
                                        writeToLog: self.writeToLog(_:)))
        }
    }

    func getRejectProbability() -> Double {
        Double(getRejectedRequestsAmount()) / Double(getGeneratedRequestsAmount())
    }

    func getCompletedRequests(from generator: UInt) -> [Request] {
        var requests = [Request]()
        for processor in processors {
            processor.completedRequests.forEach({
                if $0.creatorNumber == generator {
                    requests.append($0)
                }
            })
        }
        return requests
    }

    func getCompletedRequestsAmount() -> UInt {
        var res = 0 as UInt
        processors.forEach({
            res += UInt($0.requestsCount)
        })
        return res
    }

    func getGeneratedRequestsAmount() -> UInt {
        var res = 0 as UInt
        generators.forEach({
            res += UInt($0.requestsCount)
        })
        return res
    }

    func getRejectedRequestsAmount() -> UInt {
        bufferInserter.getRejectedRequestsAmount()
    }

    func getRejectedRequestsAmount(creatorNumber: UInt) -> UInt {
        bufferInserter.getRejectedRequestsAmount(creatorNumber: creatorNumber)
    }

    func getAllRejectedRequests() -> [Request] {
        var res = [Request]()
        bufferInserter.rejectedRequests.forEach({
            $0.forEach({
                res.append($0)
            })
        })
        return res
    }

    func getRejectedRequests() -> [[Request]] {
        bufferInserter.rejectedRequests
    }
    
    func getAverageRequestStayTime() -> Double {
        guard !generators.isEmpty else {
            return -1.0
        }
        var totalTime = 0.0
        var totalCount = 0
        
        for index in 1...generators.count {
            let stayTime = getAverageRequestStayTime(generatorNumber: UInt(index))
            if !stayTime.isNaN {
                totalTime += stayTime
                totalCount += 1
            }
        }
        
        return totalTime / Double(totalCount)
    }

    func getAverageRequestStayTime(generatorNumber: UInt) -> Double {
        let requests = getCompletedRequests(from: generatorNumber)

        var totalTime = 0.0

        requests.forEach({
            if $0.completionTime != nil {
                totalTime += ($0.completionTime! - $0.creationTime)
            }
        })
        return totalTime / Double(requests.count)
    }

    func getAverageRequestWaitingTime(generatorNumber: UInt) -> Double {
        let requests = getCompletedRequests(from: generatorNumber)

        var totalTime = 0.0

        requests.forEach({
            if $0.pickTime != nil {
                totalTime += ($0.pickTime! - $0.creationTime)
            }
        })
        return totalTime / Double(requests.count)
    }

    func getAverageRequestProcessingTime(generatorNumber: UInt) -> Double {
        let requests = getCompletedRequests(from: generatorNumber)

        var totalTime = 0.0

        requests.forEach({
            if $0.pickTime != nil && $0.completionTime != nil {
                totalTime += ($0.completionTime! - $0.pickTime!)
            }
        })
        return totalTime / Double(requests.count)
    }
    
    func getAverageProcessorUsingRate() -> Double {
        guard !processors.isEmpty else {
            return -1.0
        }
        var totalRate = 0.0
        for index in 0...processors.count - 1 {
            totalRate += getProcessorUsingRate(index: UInt(index))
        }
        return totalRate / Double(processors.count)
    }
    
    func getProcessorUsingRate(index: UInt) -> Double {
        guard index < processors.count && index >= 0 else {
            return -1.0
        }
        return processors[Int(index)].bisyTime / realisationTime
    }

    func writeToLog(_ string: String) {
        eventLog.append(string + "\n")
    }

    func print() {
        for index in 0...generators.count - 1 {
            generators[index].print()
        }
        buffer.print()
        for index in 0...processors.count - 1 {
            Swift.print("  Processor " + String(index + 1) + ":")
            processors[index].print()
        }
    }

    func showCompletionAlert(iterations: UInt) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Simulation finished"
            alert.informativeText = "Automatic simulation finished after "
                + String(iterations)
                + " iterations"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

extension Simulator: SpecialConditioned {

    func getNextSCTime() -> Double {
        var nextSCTime = Double.infinity

        processors.forEach({
            if $0.getNextSCTime() < nextSCTime {
                nextSCTime = $0.getNextSCTime()
            }
        })
        generators.forEach({
            if $0.getNextSCTime() < nextSCTime {
                nextSCTime = $0.getNextSCTime()
            }
        })
        return nextSCTime
    }

    func makeStep() {
        makeStep(debug: false)
    }

    func makeStep(debug: Bool) {
        isEnabled = true

        var nextSCTime = Double.infinity
        var nextSCObject: SpecialConditioned?

        processors.forEach({
            if $0.getNextSCTime() < nextSCTime {
                nextSCTime = $0.getNextSCTime()
                nextSCObject = $0
            }
        })
        var nextSCObjectIsGenerator = false

        generators.forEach({
            if $0.getNextSCTime() < nextSCTime {
                nextSCTime = $0.getNextSCTime()
                nextSCObject = $0
                nextSCObjectIsGenerator = true
            }
        })
        realisationTime = nextSCObject?.getNextSCTime() ?? realisationTime
        nextSCObject?.makeStep()

        if nextSCObjectIsGenerator && buffer.hasRequests() {
            for index in 0...processors.count - 1 {
                if buffer.hasRequests() {
                    if processors[index].request == nil {
                        processors[index].makeStep(time: nextSCTime)
                    }
                } else {
                    break
                }
            }
        }
        stepsCounter += 1

        if debug {

            var tmp = " –––––––– Step #" + String(stepsCounter) + " –––––––– "
            tmp += "rejected: " + String(getAllRejectedRequests().count)
            if nextSCObjectIsGenerator {
                tmp += " –––––––– current SC: generator  –––––––– "
            } else {
                tmp += " –––––––– current SC: processor  –––––––– "
            }
            Swift.print(tmp)
            self.print()
            Swift.print()
        }
    }
}
