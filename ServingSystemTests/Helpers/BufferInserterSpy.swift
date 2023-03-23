//
//  BufferInserterSpy.swift
//  ServingSystemTests
//
//  Created by Andrey on 17.03.2023.
//

@testable import ServingSystem

class BufferInserterSpy: BufferInserter {
    var rejectedRequests: [[ServingSystem.Request]] = []
    var insertedRequests: [ServingSystem.Request] = []
    
    func insert(request: ServingSystem.Request) {
        insertedRequests.append(request)
    }
    
    func getRejectedRequestsAmount() -> Int {
        0
    }
    
    func getRejectedRequestsAmount(creatorNumber: Int) -> Int {
        0
    }
}
