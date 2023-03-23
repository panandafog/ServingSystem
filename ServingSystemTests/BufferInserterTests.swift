//
//  BufferInserterTests.swift
//  ServingSystemTests
//
//  Created by Andrey on 23.03.2023.
//

@testable import ServingSystem
import XCTest

final class BufferInserterTests: XCTestCase {
    
    let bufferCapacity = 5
    let generatorsCount = 5

    var bufferInserter: BufferInserter!
    var bufferMock: BufferMock!
    
    override func setUpWithError() throws {
        bufferMock = BufferMock(capacity: bufferCapacity)
        bufferInserter = BufferInserterImpl(buffer: bufferMock, generatorsCount: generatorsCount)
    }

    override func tearDownWithError() throws {
        bufferMock = nil
        bufferInserter = nil
    }
    
    func testInitialState() throws {
        
        // validate initial buffer inserter state
        
        XCTAssertEqual(
            bufferInserter.rejectedRequests.count,
            generatorsCount,
            "rejected requests 2d array should have the same size as count of generators"
        )
        XCTAssertEqual(
            bufferInserter.getRejectedRequestsAmount(),
            0,
            "buffer should not have rejected requests"
        )
        for generatorIndex in 0..<generatorsCount {
            XCTAssertEqual(
                bufferInserter.rejectedRequests[generatorIndex].count,
                0,
                "buffer should not have rejected requests"
            )
            XCTAssertEqual(
                bufferInserter.getRejectedRequestsAmount(creatorNumber: generatorIndex),
                0,
                "buffer should not have rejected requests"
            )
        }
    }
    
    func testFullfilled() throws {
        
        // insert max requests count
        
        for generatorNumber in 1...generatorsCount {
            let request = Request(name: String(generatorNumber), creatorNumber: generatorNumber, creationTime: 0.0)
            bufferInserter.insert(request: request)
        }
        
        // validate fullfilled state
        
        XCTAssertEqual(
            bufferInserter.rejectedRequests.count,
            generatorsCount,
            "rejected requests 2d array should have the same size as count of generators"
        )
        XCTAssertEqual(
            bufferInserter.getRejectedRequestsAmount(),
            0,
            "buffer should not have rejected requests"
        )
        
        for generatorIndex in 0..<generatorsCount {
            XCTAssertEqual(
                bufferInserter.rejectedRequests[generatorIndex].count,
                0,
                "buffer should not have rejected requests"
            )
            XCTAssertEqual(
                bufferInserter.getRejectedRequestsAmount(creatorNumber: generatorIndex),
                0,
                "buffer should not have rejected requests"
            )
        }
        
        for queueEntryIndex in 0..<bufferCapacity {
            XCTAssertNotNil(
                bufferMock.queue[queueEntryIndex],
                "buffer queue should be full"
            )
        }
    }

    func testBufferOverflow() throws {
        
        // simulate buffer overflow
        
        for generatorNumber in 1...generatorsCount {
            let request = Request(name: String(generatorNumber), creatorNumber: generatorNumber, creationTime: 0.0)
            bufferInserter.insert(request: request)
        }
        
        let additionalRequestsGeneratorNumbers = [1, 3]
        
        for generatorNumber in additionalRequestsGeneratorNumbers {
            let request = Request(name: String(generatorNumber), creatorNumber: generatorNumber, creationTime: 0.0)
            bufferInserter.insert(request: request)
        }
        
        // validate overflowed buffer state
        
        for generatorNumber in additionalRequestsGeneratorNumbers {
            XCTAssertEqual(
                bufferInserter.rejectedRequests[generatorNumber - 1].count,
                1,
                "buffer should have 1 rejected request"
            )
            XCTAssertEqual(
                bufferInserter.getRejectedRequestsAmount(creatorNumber: generatorNumber),
                1,
                "buffer should have 1 rejected request"
            )
        }
    }
}
