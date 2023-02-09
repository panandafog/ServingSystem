//
//  SimulationThreadTests.swift
//  ServingSystemTests
//
//  Created by Andrey on 09.02.2023.
//

@testable import ServingSystem
import XCTest

final class SimulationThreadTests: XCTestCase {

    func testExample() throws {
        let simulator = Simulator()
        let expectation = self.expectation(description: #function)
        let thread = SimulationThread(simulator: simulator) {
            expectation.fulfill()
        }
        thread.alerts = false
        thread.start()
        waitForExpectations(timeout: 10)
    }
}
