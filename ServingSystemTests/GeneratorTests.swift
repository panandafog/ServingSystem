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
        let requestsCount = 10
        
        Array(0..<requestsCount).forEach { _ in
            generator.makeStep()
        }
        
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.count,
            requestsCount
        )
    }
    
    func testGeneratorInsertedRequestsTime() throws {
        let nextTime = generator.nextSCTime
        generator.makeStep()
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.last?.creationTime,
            0.0
        )
        generator.makeStep()
        
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.last?.creationTime,
            nextTime
        )
    }
    
    func testGeneratorOff() throws {
        let nextTime = generator.nextSCTime
        generator.makeStep()
        generator.makeStep()
        
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.last?.creationTime,
            nextTime
        )
        
        generator.off()
        generator.makeStep()
        // FIXME: после off время д.б. 0?
        XCTAssertEqual(
            bufferInserterSpy.insertedRequests.last?.creationTime,
            0.0
        )
    }
}
