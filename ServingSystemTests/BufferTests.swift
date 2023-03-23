//
//  BufferTests.swift
//  ServingSystemTests
//
//  Created by Andrey on 17.03.2023.
//

@testable import ServingSystem
import XCTest

final class BufferTests: XCTestCase {
    
    let bufferCapacity = 4
    var buffer: Buffer!

    override func setUpWithError() throws {
        buffer = BufferImpl(capacity: bufferCapacity)
    }

    override func tearDownWithError() throws {
        buffer = nil
    }

    func testCapacity() throws {
        
        // validate queue capacity
        
        XCTAssertEqual(
            buffer.queue.count,
            bufferCapacity,
            "queue capacity should be equal to buffer capacity"
        )
    }
}
