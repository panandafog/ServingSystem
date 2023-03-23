//
//  SpecialConditioned.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

protocol SpecialConditioned {
    var nextSCTime: Double { get }
    
    func makeStep()
}
