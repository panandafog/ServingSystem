//
//  Processor.swift
//  ServingSystem
//
//  Created by panandafog on 22.09.2020.
//

import Foundation

class Processor {

    private let bufferPicker: BufferPicker

    private(set) var time = 0.0
    private(set) var cooldown: Double
    private(set) var requestsCount = 0

    private(set) var request: Request? = nil
    private(set) var completedRequests = [Request]()

    init(initialCooldown: Double, bufferPicker: BufferPicker) {
        self.cooldown = initialCooldown
        self.bufferPicker = bufferPicker
    }

    convenience init(initialCooldown: Double, bufferPicker: BufferPicker, initialTime: Double) {
        self.init(initialCooldown: initialCooldown, bufferPicker: bufferPicker)
        self.time = initialTime
    }

    private func getRequest() {
        request = bufferPicker.pick()
        if request != nil {
            self.cooldown = exp(Double(requestsCount))
        }
    }

    private func completeRequest() {
        completedRequests.append(request!)
        request!.isCompleted = true
        request = nil
        time += cooldown
        requestsCount += 1
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

        if request == nil { return }

        completeRequest()
        getRequest()
    }

    func makeStep(time: Double) {

        if request != nil { return }

        getRequest()
    }
}
