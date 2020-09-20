//
//  ViewController.swift
//  ServingSystem
//
//  Created by panandafog on 16.09.2020.
//  Copyright © 2020 panandafog. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    // MARK: - Launch mode

    @IBOutlet var modeSelector: NSPopUpButton!
    @IBOutlet var modeTab: NSTabView!

    // MARK: - General settings

    @IBOutlet var sourcesAmountField: TypedNSTextField!
    @IBOutlet var bufferCapacityField: TypedNSTextField!
    @IBOutlet var handlersAmountField: TypedNSTextField!

    var sourcesAmount: Int?
    var bufferCapacity: Int?
    var handlersAmount: Int?

    // MARK: - Buttons

    @IBOutlet var startSimulationButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        startSimulationButton.action = #selector(self.startSimulation(_:))
        sourcesAmountField.action = #selector(self.textFieldDidChange(_:))
        bufferCapacityField.action = #selector(self.textFieldDidChange(_:))
        handlersAmountField.action = #selector(self.textFieldDidChange(_:))

        sourcesAmountField.type = .positiveInt
        bufferCapacityField.type = .positiveInt
        handlersAmountField.type = .positiveInt

        sourcesAmount = Int(sourcesAmountField.stringValue)
        bufferCapacity = Int(bufferCapacityField.stringValue)
        handlersAmount = Int(handlersAmountField.stringValue)

        handlersAmountField.delegate = self
    }

    override var representedObject: Any? {
        didSet { }
    }

    @IBAction func modeChanged(_ sender: NSPopUpButton) {
        modeTab.selectTabViewItem(at: sender.indexOfSelectedItem)
    }

    @objc func startSimulation(_ sender: NSButton) {
        print("Start button clicked")
    }

    @objc func textFieldDidChange(_ sender: TypedNSTextField) {
        startSimulationButton.isEnabled = validateSettings()
    }

    func validateSettings() -> Bool {
        return sourcesAmountField.validateType() && bufferCapacityField.validateType() && handlersAmountField.validateType()

        // TODO: validate selected mode settings
    }
}

