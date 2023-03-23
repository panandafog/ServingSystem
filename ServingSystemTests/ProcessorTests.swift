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
        
        // make initial step
        
        let initialTime = 1.0
        bufferPickerStub.request = Request(name: "1", creatorNumber: processorNumber, creationTime: 0.0)
        
        processor.makeStep(time: initialTime)
        
        // check first request generation
        
        XCTAssertNotNil(
            processor.request,
            "processor should have assigned request"
        )
        XCTAssertTrue(
            processor.request?.pickTime == initialTime,
            "requests's pick time should be equal to inital time"
        )
        XCTAssertFalse(
            processor.request?.isCompleted ?? true,
            "after first step request should be completed"
        )
        XCTAssertEqual(
            processor.time, initialTime,
            "processors' pick time should be equal to inital"
        )
    }
    
    func testMakingStep() throws {
        
        // make initial step
        
        let initialTime = 1.0
        let firstRequest = Request(name: "1", creatorNumber: processorNumber, creationTime: 0.0)
        bufferPickerStub.request = firstRequest
        
        processor.makeStep(time: initialTime)
        
        // make second step
        
        let secondRequest = Request(name: "2", creatorNumber: processorNumber, creationTime: 1.0)
        bufferPickerStub.request = secondRequest
        
        processor.makeStep()
        
        // processor state validation
        
        XCTAssertEqual(
            processor.request?.name,
            secondRequest.name,
            "processor should have second request assigned"
        )
        XCTAssertTrue(
            processor.request?.pickTime ?? initialTime > initialTime,
            "second request's pick time should be more then initial time"
        )
        XCTAssertFalse(
            processor.request?.isCompleted ?? true,
            "processor's request should be completed"
        )
        XCTAssertTrue(
            processor.time > initialTime,
            "processor's time should be more then initial time"
        )
        XCTAssertEqual(
            processor.bisyTime,
            processor.time - initialTime,
            "processor's bisy should be equal to processor's time - initial time"
        )
        XCTAssertEqual(
            processor.requestsCount,
            1,
            "processor's completed requests count should be 1"
        )
        XCTAssertEqual(
            processor.completedRequests.count,
            1,
            "processor's completed requests count should be 1"
        )
        XCTAssertEqual(
            processor.completedRequests.last?.name,
            firstRequest.name,
            "processor's last request should be first generated"
        )
    }
}
