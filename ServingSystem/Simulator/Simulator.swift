//
//  Simulator.swift
//  ServingSystem
//
//  Created by panandafog on 22.09.2020.
//

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

    init(generatorsCount: UInt, generatorsCooldown: Double, processorsCount: UInt, processorsCooldown: Double, bufferCapacity: UInt) {

        buffer = Buffer(capacity: bufferCapacity)
        bufferPicker = BufferPicker(buffer: buffer)
        bufferInserter = BufferInserter(buffer: buffer, generatorsCount: generatorsCount)

        for index in 1...generatorsCount {
            generators.append(Generator(priority: Int(index),
                                        cooldown: generatorsCooldown + 0.1 * Double(index),
                                        bufferInserter: bufferInserter,
                                        writeToLog: self.writeToLog(_:)))
        }

        for index in 1...processorsCount {
            processors.append(Processor(number: index,
                                        initialCooldown: processorsCooldown + 0.1 * Double(index),
                                        bufferPicker: bufferPicker,
                                        writeToLog: self.writeToLog(_:)))
        }
    }

    func makeSteps(_ steps: UInt) {
        for _ in 1...steps {
            makeStep()
        }
    }

    func startAutoSimulation(initialRequestsAmount: UInt) {
        var previousRequestAmount = initialRequestsAmount
        var currentRequestsAmount = previousRequestAmount

        makeSteps(currentRequestsAmount)
        var currentRejectProbability = getRejectProbability()
        var previousRejectProbability = currentRejectProbability

        repeat {
            previousRequestAmount = currentRequestsAmount
            if currentRejectProbability == 0 {
                break
            }
            currentRequestsAmount = previousRequestAmount + UInt((2.699_449 * (1.0 - currentRejectProbability)) / (currentRejectProbability * 0.01))

            Swift.print("req amount: " + String(currentRequestsAmount))
            Swift.print("rej prob:   " + String(currentRejectProbability))
            makeSteps(currentRequestsAmount)

            previousRejectProbability = currentRejectProbability
            currentRejectProbability = getRejectProbability()
        } while abs(previousRejectProbability - currentRejectProbability) >= (0.1 * previousRejectProbability)

//        Swift.print("End auto simulation")
//        Swift.print(String(previousRejectProbability))
//        Swift.print(String(currentRejectProbability))
//        Swift.print(String(previousRequestAmount))
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

    func getRejectedRequestsAmount(processorNumber: UInt) -> UInt {
        bufferInserter.getRejectedRequestsAmount(processorNumber: processorNumber)
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
