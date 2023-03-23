//
//  SimulationThread.swift
//  ServingSystem
//
//  Created by panandafog on 18.10.2020.
//

import Foundation

class SimulationThread: Thread {

    var alerts = true
    private let simulator: Simulator
    private let completion: () -> Void

    init(simulator: Simulator, completion: @escaping () -> Void) {
        self.simulator = simulator
        self.completion = completion
    }

    override func main() {
        var previousRequestAmount = SimulationProperties.shared.iterationsCount
        var currentRequestsAmount = previousRequestAmount

        makeSteps(currentRequestsAmount)
        var currentRejectProbability = simulator.getRejectProbability()
        var previousRejectProbability = currentRejectProbability

        if !isCancelled {
            repeat {
                previousRequestAmount = currentRequestsAmount
                if currentRejectProbability == 0 {
                    break
                }
                currentRequestsAmount = previousRequestAmount + Int((2.699449 * (1.0 - currentRejectProbability)) / (currentRejectProbability * 0.01))

                makeSteps(currentRequestsAmount)

                previousRejectProbability = currentRejectProbability
                currentRejectProbability = simulator.getRejectProbability()

            } while abs(previousRejectProbability - currentRejectProbability) >= (0.1 * previousRejectProbability) && !isCancelled
        }
        completion()
        if !isCancelled && alerts {
            simulator.showCompletionAlert(iterations: currentRequestsAmount)
        }
    }

    private func makeSteps(_ steps: Int) {
        for _ in 1...steps {
            simulator.makeStep()
            if isCancelled {
                return
            }
        }
    }
}
