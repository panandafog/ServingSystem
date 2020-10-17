//
//  Maths.swift
//  ServingSystem
//
//  Created by panandafog on 13.10.2020.
//

import Cocoa

class Maths {

    static func expectation(of mas: [Double]) -> Double {
        var sum = 0.0
        mas.forEach({ sum += $0 })

        let count = Double(mas.count)
        var expectation = 0.0

        mas.forEach({ expectation += $0 * 1 / count })

        return expectation
    }

    static func dispersion(of mas: [Double]) -> Double {
        expectation(of: mas.map({ pow($0, 2) })) - pow(expectation(of: mas), 2)
    }
}
