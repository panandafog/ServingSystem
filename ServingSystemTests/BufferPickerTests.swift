//
//  BufferPickerTests.swift
//  ServingSystemTests
//
//  Created by Andrey on 23.03.2023.
//

@testable import ServingSystem
import XCTest

final class BufferPickerTests: XCTestCase {
    
    let generatorsCount = 5

    var bufferPicker: BufferPicker!
    var bufferMock: BufferMock!

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        bufferMock = nil
        bufferPicker = nil
    }

    func testPriorityPick() throws {
        // fill the queue
        
        let bufferCapacity = 5
        let bufferQueue: [Request?] = (1...generatorsCount).map {
            Request(name: String($0), creatorNumber: $0, creationTime: 0.0)
        }
        
        // create picker
        
        bufferMock = BufferMock(capacity: bufferCapacity, queue: bufferQueue)
        bufferPicker = BufferPicker(buffer: bufferMock)
        
        // validate picked request
        
        let pickedRequest = bufferPicker.pick()
        XCTAssertEqual(pickedRequest?.creatorNumber, 1)
    }
    
    func testPriorityPick2() throws {
        // fill the queue
        
        let bufferQueue: [Request?] = [
            Request(name: "3", creatorNumber: 3, creationTime: 0.0),
            Request(name: "1", creatorNumber: 1, creationTime: 0.0),
            Request(name: "2", creatorNumber: 2, creationTime: 0.0),
        ]
        let bufferCapacity = bufferQueue.count
        
        // create picker
        
        bufferMock = BufferMock(capacity: bufferCapacity, queue: bufferQueue)
        bufferPicker = BufferPicker(buffer: bufferMock)
        
        // validate picked request
        
        let pickedRequest = bufferPicker.pick()
        XCTAssertEqual(pickedRequest?.creatorNumber, 1)
    }
    
    func testTimePick() throws {
        // fill the queue
        
        let bufferQueue: [Request?] = [
            Request(name: "3", creatorNumber: 3, creationTime: 0.0),
            Request(name: "1", creatorNumber: 1, creationTime: 1.0),
            Request(name: "1", creatorNumber: 1, creationTime: 0.0),
            Request(name: "2", creatorNumber: 2, creationTime: 0.0)
        ]
        let bufferCapacity = bufferQueue.count
        
        // create picker
        
        bufferMock = BufferMock(capacity: bufferCapacity, queue: bufferQueue)
        bufferPicker = BufferPicker(buffer: bufferMock)
        
        // validate picked request
        
        let pickedRequest = bufferPicker.pick()
        XCTAssertEqual(pickedRequest?.creatorNumber, 1)
        XCTAssertEqual(pickedRequest?.creationTime, 0.0)
    }
    func testTimePick2() throws {
        // fill the queue
        
        let bufferQueue: [Request?] = [
            Request(name: "3", creatorNumber: 3, creationTime: 0.0),
            Request(name: "1", creatorNumber: 1, creationTime: 1.0),
            Request(name: "2", creatorNumber: 2, creationTime: 0.0)
        ]
        let bufferCapacity = bufferQueue.count
        
        // create picker
        
        bufferMock = BufferMock(capacity: bufferCapacity, queue: bufferQueue)
        bufferPicker = BufferPicker(buffer: bufferMock)
        
        // validate picked request
        
        let pickedRequest = bufferPicker.pick()
        XCTAssertEqual(pickedRequest?.creatorNumber, 1)
    }
}
