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

    func testExample() throws {
        
    }
}
