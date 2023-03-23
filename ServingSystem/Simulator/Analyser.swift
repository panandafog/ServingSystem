//
//  Analyser.swift
//  ServingSystem
//
//  Created by panandafog on 29.10.2020.
//

import Foundation

class Analyser {
    
    let packageCapacity = 100
    
    var mode = Mode.processorsAmount
    
    var minValue = Int(SimulationProperties.shared.processorsAmount)
    var maxValue = Int(SimulationProperties.shared.processorsAmount + 5)
    
    var completion: ((_: Analyser.Mode?, _: [Int]?, _: [Double]?, _: [Double]?, _: [Double]?) -> Void)?
    
    private (set) var working = false
    
    private var valuesAmount = 0
    private var completedValuesAmount = 0
    
    private var packageValuesAmount = 0
    private var packageCompletedValuesAmount = 0
    private var threads = [SimulationThread]()
    
    private var rejectProbability = [Double]()
    private var stayTime = [Double]()
    private var usingRate = [Double]()
    
    func start() {
        
        completedValuesAmount = 0
        packageCompletedValuesAmount = 0
        working = true
        valuesAmount = maxValue - minValue + 1
        
        rejectProbability = [Double](repeating: -1.0, count: valuesAmount)
        stayTime = [Double](repeating: -1.0, count: valuesAmount)
        usingRate = [Double](repeating: -1.0, count: valuesAmount)
        
        if valuesAmount > self.packageCapacity {
            launchPackage(minValue: minValue, maxValue: minValue + packageCapacity - 1)
        } else {
            launchPackage(minValue: minValue, maxValue: maxValue)
        }
    }
    
    func cancel() {
        working = false
        threads.forEach({
            $0.cancel()
        })
        threads = []
    }
    
    func updateValuesFor(mode: Mode) {
        self.mode = mode
        
        switch mode {
        case .bufferCapacity:
            minValue = Int(SimulationProperties.shared.bufferCapacity)
            maxValue = Int(SimulationProperties.shared.bufferCapacity + 5)
        case .generatorsAmount:
            minValue = Int(SimulationProperties.shared.generatorsAmount)
            maxValue = Int(SimulationProperties.shared.generatorsAmount + 5)
        default:
            minValue = Int(SimulationProperties.shared.processorsAmount)
            maxValue = Int(SimulationProperties.shared.processorsAmount + 5)
        }
    }
    
    private func launchPackage(minValue: Int, maxValue: Int) {
        self.packageCompletedValuesAmount = 0
        self.packageValuesAmount = maxValue - minValue + 1
        
        var index = completedValuesAmount - 1
        for value in minValue...maxValue {
            index += 1
            
            var simulator: Simulator?
            
            switch mode {
            case .bufferCapacity:
                simulator = Simulator(bufferCapacity: value)
            case .generatorsAmount:
                simulator = Simulator(generatorsAmount: value)
            default:
                simulator = Simulator(processorsAmount: value)
            }
            
            guard let nNsimulator = simulator else {
                return
            }
            
            let index = index
            
            let simulationThread = SimulationThread(simulator: nNsimulator, completion: ({
                guard self.working else {
                    return
                }
                
                self.rejectProbability[index] = nNsimulator.getRejectProbability()
                self.stayTime[index] = nNsimulator.getAverageRequestStayTime()
                self.usingRate[index] = nNsimulator.getAverageProcessorUsingRate()
                
                self.completedValuesAmount += 1
                self.packageCompletedValuesAmount += 1
                
                print(self.completedValuesAmount)
                
                if self.packageCompletedValuesAmount == self.packageValuesAmount {
                    if self.completedValuesAmount < self.valuesAmount {
                        let minValue = self.minValue + self.completedValuesAmount
                        var maxValue = minValue + self.packageCapacity
                        if maxValue > self.maxValue {
                            maxValue = self.maxValue
                        }
                        DispatchQueue.global().async {
                            self.launchPackage(minValue: minValue, maxValue: maxValue)
                        }
                    } else {
                        self.completion?(self.mode, Array(self.minValue...self.maxValue), self.rejectProbability, self.stayTime, self.usingRate)
                        self.working = false
                    }
                }
            }))
            simulationThread.alerts = false
            simulationThread.start()
            threads.append(simulationThread)
        }
    }
}

extension Analyser {
    
    enum Mode: String, CaseIterable {
        case generatorsAmount = "Vary generators amount"
        case processorsAmount = "Vary processors amount"
        case bufferCapacity = "Vary buffer capacity"
    }
}
