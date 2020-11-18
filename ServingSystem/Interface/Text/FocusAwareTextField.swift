//
//  FocusAwareTextField.swift
//  ServingSystem
//
//  Created by panandafog on 18.11.2020.
//

import Cocoa

class FocusAwareTextField: NSTextField {
    var onFocus: (_: NSTextField) -> Void = { _ in }
    
    override func becomeFirstResponder() -> Bool {
        onFocus(self)
        return super.becomeFirstResponder()
    }
}
