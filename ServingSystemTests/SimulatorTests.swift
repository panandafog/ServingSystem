//
//  SimulatorTests.swift
//  ServingSystemTests
//
//  Created by Andrey on 23.03.2023.
//

@testable import ServingSystem
import XCTest

final class SimulatorTests: XCTestCase {
    
    let generatorsAmount = 5
    let processorsAmount = 3
    
    var simulator: Simulator!
    var bufferMock: BufferMock!
    var bufferPickerStub: BufferPickerStub!
    var bufferInserterSpy: BufferInserterSpy!

    override func setUpWithError() throws {
        bufferMock = BufferMock(capacity: generatorsAmount)
        bufferPickerStub = BufferPickerStub()
        bufferInserterSpy = BufferInserterSpy()
        
        simulator = SimulatorImpl(
            buffer: bufferMock,
            bufferPicker: bufferPickerStub,
            bufferInserter: bufferInserterSpy,
            generatorsAmount: generatorsAmount,
            processorsAmount: processorsAmount
        )
    }

    override func tearDownWithError() throws {
        bufferMock = nil
        bufferPickerStub = nil
        bufferInserterSpy = nil
        simulator = nil
    }

    func testSteps() throws {
        
        // make a few steps
        
        let stepsCount = 50
        for _ in 0..<stepsCount {
            let timeBeforeStep = simulator.nextSCTime
            simulator.makeStep()
            
            // validate next step time
            
            XCTAssertTrue(
                simulator.nextSCTime >= timeBeforeStep,
                "next SC time shoud increase while making steps"
            )
        }
        XCTAssertFalse(
            bufferInserterSpy.insertedRequests.isEmpty,
            "inserted requests should exist"
        )
    }
    
    func testSimulationResults() {
        let simulator = SimulatorImpl()
        for _ in 0..<1000 {
            simulator.makeStep()
        }
        XCTAssertTrue(
            simulator.getRejectProbability() > 0,
            "reject probability should be between 0 and 1"
        )
        XCTAssertTrue(
            simulator.getRejectProbability() < 1,
            "reject probability should be between 0 and 1"
        )
        XCTAssertTrue(
            simulator.getRejectedRequestsAmount() > 0,
            "rejected requests should exist"
        )
        XCTAssertTrue(
            simulator.getRejectedRequestsAmount(creatorNumber: 1) > 0,
            "rejected requests from first generator should exist"
        )
        XCTAssertTrue(
            simulator.getRejectedRequestsAmount(creatorNumber: 1) < simulator.getRejectedRequestsAmount(),
            "count of rejected requests from first generator should be less then all rejected requests count"
        )
        XCTAssertTrue(
            simulator.getCompletedRequestsAmount() > 0,
            "completed requests should exist"
        )
        XCTAssertTrue(
            simulator.getGeneratedRequestsAmount() > simulator.getCompletedRequestsAmount(),
            "count of completed requests should be less then all generated requests count"
        )
        XCTAssertTrue(
            simulator.getGeneratedRequestsAmount() > simulator.getRejectedRequestsAmount(),
            "count of rejected requests should be less then all generated requests count"
        )
        XCTAssertTrue(
            simulator.getAverageRequestStayTime() > 0,
            "average request stay time should be between 0 and 1"
        )
        XCTAssertTrue(
            simulator.getAverageProcessorUsingRate() > 0,
            "using rate should be between 0 and 1"
        )
        XCTAssertTrue(
            simulator.getAverageProcessorUsingRate() <= 1,
            "using rate should be between 0 and 1"
        )
    }
}
