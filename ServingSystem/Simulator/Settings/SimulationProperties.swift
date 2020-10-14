//
//  SimulationProperties.swift
//  ServingSystem
//
//  Created by panandafog on 14.10.2020.
//

import Cocoa

class SimulationProperties {

    static let shared = SimulationProperties()

    private (set) var commonGenerationProperties: GenerationProperties?
    private (set) var commonProcessingProperties: ProcessingProperties?

    private let initialGenerationProperties = GenerationProperties(cooldown: 1.0, function: .linear)
    private let initialProcessingProperties = ProcessingProperties(minTime: 0.0, maxTime: 1.0, function: .randomWithExponent)

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

        commonGenerationProperties = initialGenerationProperties
        commonProcessingProperties = initialProcessingProperties

        guard let commonGenerationProperties = commonGenerationProperties,
              let commonProcessingProperties = commonProcessingProperties else {
            return
        }

        for _ in currentGenerationProperties {
            currentGenerationProperties.append(commonGenerationProperties)
        }

        for _ in currentProcessingProperties {
            currentProcessingProperties.append(commonProcessingProperties)
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

        commonGenerationProperties = GenerationProperties(cooldown: cooldown, function: function)
    }

    func applyToAllGenerators(properties: GenerationProperties) {
        applyToAllGenerators(cooldown: properties.cooldown, function: properties.function)
    }

    func addGeneratorProperties() {
        if commonGenerationProperties != nil {
            currentGenerationProperties.append(commonGenerationProperties!)
        } else {
            if !currentGenerationProperties.isEmpty {
                let ind = currentGenerationProperties.count - 1
                currentGenerationProperties.append(currentGenerationProperties[ind])
            } else {
                commonGenerationProperties = initialGenerationProperties
                currentGenerationProperties.append(initialGenerationProperties)
            }
        }
    }

    func addGeneratorProperties(properties: GenerationProperties) {
        commonGenerationProperties = nil
        currentGenerationProperties.append(properties)
    }

    func removeGeneratorProperties(index: UInt) {
        if index < currentGenerationProperties.count {
            currentGenerationProperties.remove(at: Int(index))
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

        commonProcessingProperties = ProcessingProperties(minTime: minTime, maxTime: maxTime, function: function)
    }

    func applyToAllProcessors(properties: ProcessingProperties) {
        applyToAllProcessors(minTime: properties.minTime, maxTime: properties.maxTime, function: properties.function)
    }

    func addProcessorProperties() {
        if commonProcessingProperties != nil {
            currentProcessingProperties.append(commonProcessingProperties!)
        } else {
            if !currentProcessingProperties.isEmpty {
                let ind = currentProcessingProperties.count - 1
                currentProcessingProperties.append(currentProcessingProperties[ind])
            } else {
                commonProcessingProperties = initialProcessingProperties
                currentProcessingProperties.append(initialProcessingProperties)
            }
        }
    }

    func addProcessorProperties(properties: ProcessingProperties) {
        commonProcessingProperties = nil
        currentProcessingProperties.append(properties)
    }

    func removeProcessorProperties(index: UInt) {
        if index < currentProcessingProperties.count {
            currentProcessingProperties.remove(at: Int(index))
        }
    }
}
