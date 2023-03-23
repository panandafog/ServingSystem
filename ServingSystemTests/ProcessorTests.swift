//
//  ProcessorTests.swift
//  ServingSystemTests
//
//  Created by Andrey on 23.03.2023.
//

@testable import ServingSystem
import XCTest

final class ProcessorTests: XCTestCase {
    
    let processorNumber = 2
    
    var bufferPickerStub: BufferPickerStub!
    var processor: Processor!

    override func setUpWithError() throws {
        bufferPickerStub = BufferPickerStub()
        processor = Processor(number: processorNumber, bufferPicker: bufferPickerStub, simulator: nil)
    }

    override func tearDownWithError() throws {
        bufferPickerStub = nil
        processor = nil
    }

    func testInitialStep() throws {
        let initialTime = 1.0
        bufferPickerStub.request = Request(name: "1", creatorNumber: processorNumber, creationTime: 0.0)
        
        processor.makeStep(time: initialTime)
        
        XCTAssertNotNil(processor.request)
        XCTAssertTrue(processor.request?.pickTime == initialTime)
        XCTAssertFalse(processor.request?.isCompleted ?? true)
        XCTAssertEqual(processor.time, initialTime)
    }
    
    func testMakingStep() throws {
        let initialTime = 1.0
        let firstRequest = Request(name: "1", creatorNumber: processorNumber, creationTime: 0.0)
        bufferPickerStub.request = firstRequest
        
        processor.makeStep(time: initialTime)
        
        let secondRequest = Request(name: "2", creatorNumber: processorNumber, creationTime: 1.0)
        bufferPickerStub.request = secondRequest
        
        processor.makeStep()
        
        XCTAssertEqual(processor.request?.name, secondRequest.name)
        XCTAssertTrue(processor.request?.pickTime ?? initialTime > initialTime)
        XCTAssertFalse(processor.request?.isCompleted ?? true)
        XCTAssertTrue(processor.time > initialTime)
        XCTAssertEqual(processor.bisyTime, processor.time - initialTime)
        XCTAssertEqual(processor.requestsCount, 1)
        XCTAssertEqual(processor.completedRequests.count, 1)
        XCTAssertEqual(processor.completedRequests.last?.name, firstRequest.name)
    }
}
