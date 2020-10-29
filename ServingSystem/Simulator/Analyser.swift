//
//  Analyser.swift
//  ServingSystem
//
//  Created by panandafog on 29.10.2020.
//

import Foundation

class Analyser {
    
    var mode = Mode.generatorsAmount
    
    var minValue = Int(SimulationProperties.shared.generatorsAmount)
    var maxValue = Int(SimulationProperties.shared.generatorsAmount + 5)
    
    var completion: ((_: [Double]?, _: [Double]?, _: [Double]?) -> Void)?
    
    private (set) var working = false
    
    private var valuesAmount = 0
    private var completedValuesAmount = 0
    private var threads = [SimulationThread]()
    
    private var rejectProbability = [Double]()
    private var stayTime = [Double]()
    private var usingRate = [Double]()
    
    func start() {
        
        completedValuesAmount = 0
        working = true
        valuesAmount = maxValue - minValue + 1

        rejectProbability = [Double](repeating: 0.0, count: valuesAmount)
        stayTime = [Double](repeating: 0.0, count: valuesAmount)
        usingRate = [Double](repeating: 0.0, count: valuesAmount)
        
        var index = -1
        for value in minValue...maxValue {
            index += 1
            
            var simulator: Simulator?
            
            switch mode {
            case .bufferCapacity:
                simulator = Simulator(bufferCapacity: UInt(value))
            case .generatorsAmount:
                simulator = Simulator(generatorsAmount: UInt(value))
            default:
                simulator = Simulator(processorsAmount: UInt(value))
            }
            
            guard let nNsimulator = simulator else {
                return
            }
        
            let simulationThread = SimulationThread(simulator: nNsimulator, completion: ({
                self.rejectProbability[index] = nNsimulator.getRejectProbability()
                self.stayTime[index] = nNsimulator.getAverageRequestStayTime()
                self.usingRate[index] = nNsimulator.getAverageProcessorUsingRate()
                
                self.completedValuesAmount += 1
                
                if self.completedValuesAmount == self.valuesAmount {
                    self.working = false
                    
                    guard let globalCompletion = self.completion else {
                        return
                    }
                    
                    globalCompletion(self.rejectProbability, self.stayTime, self.usingRate)
                }
            }))
            simulationThread.alerts = false
            simulationThread.start()
        }
    }
    
    func cancel() {
        threads.forEach({
            $0.cancel()
        })
        working = false
    }
}

extension Analyser {
    
    enum Mode: String {
        case generatorsAmount = "Vary generators amount"
        case processorsAmount = "Vary processors amount"
        case bufferCapacity = "Vary buffer capacity"
    }
}
