//
//  TypedNSTextField.swift
//  ServingSystem
//
//  Created by panandafog on 17.09.2020.
//  Copyright © 2020 panandafog. All rights reserved.
//

import Cocoa

// MARK: - TypedNSTextField
class TypedNSTextField: NSTextField {

    var type: TextFieldType?
    var canBeNull = false
    var canBeZero = false

    func validateType() -> Bool {

        let value = self.stringValue

        if value == "" {
            return false
        }

        switch (type) {
        case .positiveInt:

            guard let validatedValue = Int(value) else {
                return false
            }

            if (canBeZero && validatedValue >= 0) || (validatedValue >= 1) {
                return true
            }

            return false

        case .positiveDouble:

            guard let validatedValue = Double(value) else {
                return false
            }

            if (canBeZero && validatedValue >= 0) || (validatedValue >= 1) {
                return true
            }

            return false

        default:
            return true
        }
    }
}
