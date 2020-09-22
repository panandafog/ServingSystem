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
    private(set) var isEnabled = false

    init(generatorsCount: UInt, generatorsCooldown: Double, processorsCount: UInt, processorsCooldown: Double,  bufferCapacity: UInt) {

        buffer = Buffer(capacity: bufferCapacity)
        bufferPicker = BufferPicker(buffer: buffer)
        bufferInserter = BufferInserter(buffer: buffer)

        for index in 1...generatorsCount {
            generators.append(Generator(priority: Int(index), cooldown: generatorsCooldown + 0.1 * Double(index), bufferInserter: bufferInserter))
        }

        for index in 1...processorsCount {
            processors.append(Processor(initialCooldown: processorsCooldown + 0.1 * Double(index), bufferPicker: bufferPicker))
        }
    }

    func makeSteps(_ steps: UInt) {
        for _ in 1...steps {
            makeStep()
        }
    }

    func getRejectedRequests() -> [Request] {
        return bufferInserter.bin
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

        nextSCObject?.makeStep()

        if nextSCObjectIsGenerator {
            processors.forEach({
                if $0.request == nil {
                    $0.makeStep(time: nextSCTime)
                }
            })
        }
        stepsCounter += 1

        if debug {

            var tmp = " –––––––– Step #" + String(stepsCounter) + " –––––––– "
            tmp += "rejected: " + String(getRejectedRequests().count)
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

