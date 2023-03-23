//
//  GeneratorTests.swift
//  ServingSystemTests
//
//  Created by Andrey on 17.03.2023.
//

@testable import ServingSystem
import XCTest

final class GeneratorTests: XCTestCase {
    
    var generator: Generator!
    var bufferInserterSpy: BufferInserterSpy!
    
    override func setUpWithError() throws {
        bufferInserterSpy = BufferInserterSpy()
        generator = Generator(priority: 1, bufferInserter: bufferInserterSpy, simulator: nil)
    }
    
    override func tearDownWithError() throws {
        generator = nil
        bufferInserterSpy = nil
    }
    
    func testGeneratorInsertingRequests() throws {
        
        // generate requests
        
        let requestsCount = 10
        Array(0..<requestsCount).forEach { _ in
            generator.makeStep()
        }
        
        // check count of inserted requests
        
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.count,
            requestsCount,
            "count of inserted requests should be equal to count of generated requests"
        )
        
        // check generator of inserted requests
        
        for request in bufferInserterSpy.insertedRequests {
            XCTAssertEqual(
                request.creatorNumber,
                generator.priority,
                "all inserted requests should be created by generator #" + String(generator.priority)
            )
        }
    }
    
    func testGeneratorInsertedRequestsTime() throws {
        
        // save initial time
        
        let nextTime = generator.nextSCTime
        
        // make first step
        
        generator.makeStep()
        
        // validate creation time of request
        
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.last?.creationTime,
            0.0,
            "last request creation time should be equal to initial generator's time"
        )
        
        // make second step
        
        generator.makeStep()
        
        // validate creation time of last request
        
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.last?.creationTime,
            nextTime,
            "last request creation time should be equal to generator's time after first step"
        )
    }
    
    func testGeneratorOff() throws {
        
        // make steps
        
        generator.makeStep()
        generator.makeStep()
        
        // stop generator
        
        generator.off()
        
        // make one more step
        
        generator.makeStep()
        
        // validate creation time of last request
        
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.last?.creationTime,
            Double.infinity
        )
    }
}

