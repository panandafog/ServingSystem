//
//  SimulationProperties.swift
//  ServingSystem
//
//  Created by panandafog on 14.10.2020.
//

import Cocoa

class SimulationProperties {

    static let shared = SimulationProperties()

    private let initialGenerationProperties = GenerationProperties(cooldown: 1.0, function: .linear)
    private let initialGeneratorsAmount = 5

    private let initialProcessingProperties = ProcessingProperties(minTime: 0.0, maxTime: 1.0, function: .randomWithExponent)
    private let initialProcessorsAmount = 3

    private (set) var currentGenerationProperties = [GenerationProperties]()
    private (set) var currentProcessingProperties = [ProcessingProperties]()

    var bufferCapacity = UInt(2)

    var generatorsAmount: UInt {
        UInt(currentGenerationProperties.count)
    }
    var processorsAmount: UInt {
        UInt(currentProcessingProperties.count)
    }

    // MARK: - init

    private init() {
        for _ in 1 ... initialGeneratorsAmount {
            currentGenerationProperties.append(initialGenerationProperties)
        }

        for _ in 1 ... initialProcessorsAmount {
            currentProcessingProperties.append(initialProcessingProperties)
        }
    }

    // MARK: - Generators

    func getGeneratorCooldown(generatorNumber: UInt) -> Double? {
        guard generatorNumber < generatorsAmount else {
            return nil
        }

        let currentProperties = currentGenerationProperties[Int(generatorNumber)]

        switch currentProperties.function {
        case .linear:
            return currentProperties.cooldown
        case .poisson:
            // TODO
            return currentProperties.cooldown
        }
    }

    func applyToAllGenerators(cooldown: Double, function: GenerationFunction) {
        for ind in 0 ... currentGenerationProperties.count - 1 {
            currentGenerationProperties[ind].function = function
            currentGenerationProperties[ind].cooldown = cooldown
        }
    }

    func applyToAllGenerators(properties: GenerationProperties) {
        applyToAllGenerators(cooldown: properties.cooldown, function: properties.function)
    }

    func addGeneratorProperties() {
        guard let last = currentGenerationProperties.last else {
            currentGenerationProperties.append(initialGenerationProperties)
            return
        }
        currentGenerationProperties.append(last)
    }

    func addGeneratorProperties(properties: GenerationProperties) {
        currentGenerationProperties.append(properties)
    }

    func removeGeneratorProperties(index: UInt) {
        if index < currentGenerationProperties.count - 1 {
            currentGenerationProperties.remove(at: Int(index))
        }
    }

    func removeGeneratorProperties(indices: IndexSet) {
        var intIndices = [Int]()
        for index in indices {
            if UInt(index) < currentGenerationProperties.count - 1 {
                intIndices.append(index)
            }
        }
        currentGenerationProperties.remove(at: intIndices)
    }

    func replaceGeneratorProperties(with newProperties: GenerationProperties, at index: UInt) {
        if index < currentGenerationProperties.count {
            currentGenerationProperties[Int(index)] = newProperties
        }
    }

    // MARK: - Processors

    func getProcessingCooldown(processorNumber: UInt) -> Double? {
        guard processorNumber < processorsAmount else {
            return nil
        }

        let currentProcessingTime = currentProcessingProperties[Int(processorNumber)]

        switch currentProcessingTime.function {
        case .random:
            return Double.random(in: currentProcessingTime.minTime..<currentProcessingTime.maxTime)
        case .randomWithExponent:
            return exp(Double.random(in: currentProcessingTime.minTime..<currentProcessingTime.maxTime))
        }
    }

    func applyToAllProcessors(minTime: Double, maxTime: Double, function: ProcessingFunction) {
        for ind in 0 ... currentProcessingProperties.count - 1 {
            currentProcessingProperties[ind].function = function
            currentProcessingProperties[ind].minTime = minTime
            currentProcessingProperties[ind].maxTime = maxTime
        }
    }

    func applyToAllProcessors(properties: ProcessingProperties) {
        applyToAllProcessors(minTime: properties.minTime, maxTime: properties.maxTime, function: properties.function)
    }

    func addProcessorProperties() {
        guard let last = currentProcessingProperties.last else {
            currentProcessingProperties.append(initialProcessingProperties)
            return
        }
        currentProcessingProperties.append(last)
    }

    func addProcessorProperties(properties: ProcessingProperties) {
        currentProcessingProperties.append(properties)
    }

    func removeProcessorProperties(index: UInt) {
        if index < currentProcessingProperties.count - 1 {
            currentProcessingProperties.remove(at: Int(index))
        }
    }

    func removeProcessorProperties(indices: IndexSet) {
        var intIndices = [Int]()
        for index in indices {
            if UInt(index) < currentProcessingProperties.count - 1 {
                intIndices.append(index)
            }
        }
        currentProcessingProperties.remove(at: intIndices)
    }

    func replaceProcessorProperties(with newProperties: ProcessingProperties, at index: UInt) {
        if index < currentProcessingProperties.count {
            currentProcessingProperties[Int(index)] = newProperties
        }
    }
}

extension Array {
    mutating func remove(at indices: [Int]) {
        var lastIndex: Int?
        for index in indices.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index)
            lastIndex = index
        }
    }
}