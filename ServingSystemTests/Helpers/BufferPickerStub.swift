//
//  BufferPickerStub.swift
//  ServingSystemTests
//
//  Created by Andrey on 23.03.2023.
//

@testable import ServingSystem

class BufferPickerStub: BufferPicker {
    
    var request: Request?
    
    init(request: Request? = nil) {
        self.request = request
    }
    
    func pick() -> ServingSystem.Request? {
        request
    }
}
