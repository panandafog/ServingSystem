//
//  Request.swift
//  ServingSystem
//
//  Created by panandafog on 21.09.2020.
//

struct Request {

    let name: String
    let creatorNumber: Int
    let creationTime: Double
    var isCompleted = false
    var pickTime: Double?
    var completionTime: Double?
}

extension Request: Equatable {
    static func == (lhs: Request, rhs: Request) -> Bool {
            lhs.name == rhs.name &&
            lhs.creatorNumber == rhs.creatorNumber &&
            lhs.creationTime == rhs.creationTime
    }
}
