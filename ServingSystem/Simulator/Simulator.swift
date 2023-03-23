//
//  Simulator.swift
//  ServingSystem
//
//  Created by panandafog on 22.09.2020.
//

import Cocoa

protocol Simulator: AnyObject, SpecialConditioned {
    
    var generators: [Generator] { get }
    var processors: [Processor] { get }
    var buffer: Buffer { get }
    var eventLog: String { get }
    
    func getRejectProbability() -> Double
    
    func getCompletedRequests(from generator: Int) -> [Request]
    
    func getCompletedRequestsAmount() -> Int
    
    func getGeneratedRequestsAmount() -> Int

    func getRejectedRequestsAmount() -> Int

    func getRejectedRequestsAmount(creatorNumber: Int) -> Int

    func getAllRejectedRequests() -> [Request]

    func getRejectedRequests() -> [[Request]]
    
    func getAverageRequestStayTime() -> Double

    func getAverageRequestStayTime(generatorNumber: Int) -> Double

    func getAverageRequestWaitingTime(generatorNumber: Int) -> Double

    func getAverageRequestProcessingTime(generatorNumber: Int) -> Double
    
    func getAverageProcessorUsingRate() -> Double
    
    func getProcessorUsingRate(index: Int) -> Double
    
    func showCompletionAlert(iterations: Int)
    
    func makeStep(debug: Bool)
    
    func writeToLog(_ string: String)
}

extension Simulator {
    func showCompletionAlert(iterations: Int) {
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

class SimulatorImpl: Simulator {

    var generators = [Generator]()
    var processors = [Processor]()

    var buffer: Buffer

    private var bufferPicker: BufferPicker
    private var bufferInserter: BufferInserter

    private(set) var stepsCounter = 0
    private(set) var realisationTime = 0.0
    private(set) var eventLog = ""
    private(set) var isEnabled = false

    convenience init(
        properties: SimulationProperties = SimulationProperties.shared,
        bufferCapacity: Int? = nil,
        generatorsAmount: Int? = nil,
        processorsAmount: Int? = nil
    ) {
        self.init(
            bufferCapacity: bufferCapacity ?? properties.bufferCapacity,
            generatorsAmount: generatorsAmount ?? properties.generatorsAmount,
            processorsAmount: processorsAmount ?? properties.processorsAmount
        )
    }
    
    convenience init(
        bufferCapacity: Int,
        generatorsAmount: Int,
        processorsAmount: Int
    ) {
        let buffer = BufferImpl(capacity: bufferCapacity)
        let bufferPicker = BufferPickerImpl(buffer: buffer)
        let bufferInserter = BufferInserterImpl(buffer: buffer, generatorsCount: generatorsAmount)
        
        self.init(
            buffer: buffer,
            bufferPicker: bufferPicker,
            bufferInserter: bufferInserter,
            generatorsAmount: generatorsAmount,
            processorsAmount: processorsAmount
        )
    }
    
    init(
        buffer: Buffer,
        bufferPicker: BufferPicker,
        bufferInserter: BufferInserter,
        generatorsAmount: Int,
        processorsAmount: Int
    ) {
        self.buffer = buffer
        self.bufferPicker = bufferPicker
        self.bufferInserter = bufferInserter

        for index in 1...generatorsAmount {
            generators.append(Generator(priority: Int(index),
                                        bufferInserter: bufferInserter,
                                        simulator: self))
        }

        for index in 1...processorsAmount {
            processors.append(Processor(number: index,
                                        bufferPicker: bufferPicker,
                                        simulator: self))
        }
    }

    func getRejectProbability() -> Double {
        Double(getRejectedRequestsAmount()) / Double(getGeneratedRequestsAmount())
    }

    func getCompletedRequests(from generator: Int) -> [Request] {
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

    func getCompletedRequestsAmount() -> Int {
        var res = 0
        processors.forEach({
            res += $0.requestsCount
        })
        return res
    }

    func getGeneratedRequestsAmount() -> Int {
        var res = 0
        generators.forEach({
            res += $0.requestsCount
        })
        return res
    }

    func getRejectedRequestsAmount() -> Int {
        bufferInserter.getRejectedRequestsAmount()
    }

    func getRejectedRequestsAmount(creatorNumber: Int) -> Int {
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
            let stayTime = getAverageRequestStayTime(generatorNumber: Int(index))
            if !stayTime.isNaN {
                totalTime += stayTime
                totalCount += 1
            }
        }
        
        return totalTime / Double(totalCount)
    }

    func getAverageRequestStayTime(generatorNumber: Int) -> Double {
        let requests = getCompletedRequests(from: generatorNumber)

        var totalTime = 0.0

        requests.forEach({
            if $0.completionTime != nil {
                totalTime += ($0.completionTime! - $0.creationTime)
            }
        })
        return totalTime / Double(requests.count)
    }

    func getAverageRequestWaitingTime(generatorNumber: Int) -> Double {
        let requests = getCompletedRequests(from: generatorNumber)

        var totalTime = 0.0

        requests.forEach({
            if $0.pickTime != nil {
                totalTime += ($0.pickTime! - $0.creationTime)
            }
        })
        return totalTime / Double(requests.count)
    }

    func getAverageRequestProcessingTime(generatorNumber: Int) -> Double {
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
            totalRate += getProcessorUsingRate(index: Int(index))
        }
        return totalRate / Double(processors.count)
    }
    
    func getProcessorUsingRate(index: Int) -> Double {
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
}

extension SimulatorImpl: SpecialConditioned {

    var nextSCTime: Double {
        var nextSCTime = Double.infinity

        processors.forEach({
            if $0.nextSCTime < nextSCTime {
                nextSCTime = $0.nextSCTime
            }
        })
        generators.forEach({
            if $0.nextSCTime < nextSCTime {
                nextSCTime = $0.nextSCTime
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
            if $0.nextSCTime < nextSCTime {
                nextSCTime = $0.nextSCTime
                nextSCObject = $0
            }
        })
        var nextSCObjectIsGenerator = false

        generators.forEach({
            if $0.nextSCTime < nextSCTime {
                nextSCTime = $0.nextSCTime
                nextSCObject = $0
                nextSCObjectIsGenerator = true
            }
        })
        realisationTime = nextSCObject?.nextSCTime ?? realisationTime
        nextSCObject?.makeStep()

        if nextSCObjectIsGenerator && buffer.hasRequests {
            for index in 0...processors.count - 1 {
                if buffer.hasRequests {
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
