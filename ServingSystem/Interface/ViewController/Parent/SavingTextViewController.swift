//
//  SavingTextViewController.swift
//  ServingSystem
//
//  Created by panandafog on 18.11.2020.
//

import Cocoa

class SavingTextViewController: NSViewController, NSTextFieldDelegate {
    
    var lastTextField: NSTextField?
    var controlTextDidSelected: (_: NSTextField) -> Void = { _ in
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlTextDidSelected = { sender in
            self.lastTextField = sender
        }
    }
    
    func setupTextDield(_ field: FocusAwareTextField) {
        field.delegate = self
        field.onFocus = controlTextDidSelected
    }
    
    func saveText() {
        lastTextField?.selectText(self)
    }
}
