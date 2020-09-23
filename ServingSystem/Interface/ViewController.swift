//
//  ViewController.swift
//  ServingSystem
//
//  Created by panandafog on 16.09.2020.
//  Copyright © 2020 panandafog. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    // MARK: Launch mode

    @IBOutlet var modeSelector: NSPopUpButton!
    @IBOutlet var modeTab: NSTabView!
    @IBOutlet var modeSettingsTab: NSTabView!

    // MARK: General settings

    @IBOutlet var sourcesAmountField: TypedNSTextField!
    @IBOutlet var bufferCapacityField: TypedNSTextField!
    @IBOutlet var handlersAmountField: TypedNSTextField!

    // MARK: Automatic mode

    @IBOutlet var autoSimulationIterationsField: TypedNSTextField!

    @IBOutlet var startAutoSimulationButton: NSButton!
    @IBOutlet var stopAutoSimulationButton: NSButton!

    @IBOutlet var autoSimulationProgressIndicator: NSProgressIndicator!

    // MARK: Step by step mode

    @IBOutlet var makeStepButton: NSButton!
    @IBOutlet var stopStepsSimulationButton: NSButton!

    @IBOutlet var generatorsTable: NSTableView!

    var autoSimulator: Simulator?
    var stepsSimulator: Simulator?

    override func viewDidLoad() {
        super.viewDidLoad()

        startAutoSimulationButton.action = #selector(self.startAutoSimulation(_:))
        stopAutoSimulationButton.action = #selector(self.stopAutoSimulation(_:))

        makeStepButton.action = #selector(self.makeStep(_:))
        stopStepsSimulationButton.action = #selector(self.stopStepsSimulation(_:))

        sourcesAmountField.action = #selector(self.textFieldDidChange(_:))
        bufferCapacityField.action = #selector(self.textFieldDidChange(_:))
        handlersAmountField.action = #selector(self.textFieldDidChange(_:))

        autoSimulationIterationsField.action = #selector(self.textFieldDidChange(_:))

        sourcesAmountField.type = .positiveInt
        bufferCapacityField.type = .positiveInt
        handlersAmountField.type = .positiveInt

        handlersAmountField.delegate = self
        generatorsTable.delegate = self
        generatorsTable.dataSource = self

        autoSimulationProgressIndicator.doubleValue = 0
        autoSimulationProgressIndicator.isHidden = true
    }

    override var representedObject: Any? {
        didSet { }
    }

    @IBAction func modeChanged(_ sender: NSPopUpButton) {
        modeTab.selectTabViewItem(at: sender.indexOfSelectedItem)
        modeSettingsTab.selectTabViewItem(at: sender.indexOfSelectedItem)
    }

    // MARK: - Automatic mode

    @objc func startAutoSimulation(_ sender: NSButton) {
        let generatorsCooldown = 1.0

        guard let generatorsCount = UInt(sourcesAmountField.stringValue), let processorsCount = UInt(handlersAmountField.stringValue), let bufferCapacity = UInt(bufferCapacityField.stringValue), let iterationsCount = UInt(autoSimulationIterationsField.stringValue) else {
            return
        }

        autoSimulator = Simulator(generatorsCount: generatorsCount, generatorsCooldown: generatorsCooldown, processorsCount: processorsCount, processorsCooldown: 1.0, bufferCapacity: bufferCapacity)

        startAutoSimulationButton.isEnabled = false
        stopAutoSimulationButton.isEnabled = true
        autoSimulationProgressIndicator.doubleValue = 0.0
        autoSimulationProgressIndicator.maxValue = Double(iterationsCount)
        autoSimulationProgressIndicator.isHidden = false

        DispatchQueue.global(qos: .background).async {
            for _ in 1...iterationsCount {
                if self.autoSimulator == nil {
                    break
                }
                self.autoSimulator?.makeStep(debug: true)
                DispatchQueue.main.async {
                    self.autoSimulationProgressIndicator.increment(by: 1)
                }
            }
            DispatchQueue.main.async {
                self.startAutoSimulationButton.isEnabled = true
                self.stopAutoSimulationButton.isEnabled = false
                self.autoSimulationProgressIndicator.isHidden = true
            }
        }
    }

    @objc func stopAutoSimulation(_ sender: NSButton) {
        autoSimulator = nil
        startAutoSimulationButton.isEnabled = true
        stopAutoSimulationButton.isEnabled = false
        autoSimulationProgressIndicator.doubleValue = 0.0
        autoSimulationProgressIndicator.isHidden = true
    }

    // MARK: - Step by step mode

    @objc func makeStep(_ sender: NSButton) {

        let generatorsCooldown = 1.0

        guard let generatorsCount = UInt(sourcesAmountField.stringValue), let processorsCount = UInt(handlersAmountField.stringValue), let bufferCapacity = UInt(bufferCapacityField.stringValue) else {
            return
        }

        if stepsSimulator == nil {
            stepsSimulator = Simulator(generatorsCount: generatorsCount, generatorsCooldown: generatorsCooldown, processorsCount: processorsCount, processorsCooldown: 1.0, bufferCapacity: bufferCapacity)
        }

        makeStepButton.isEnabled = false
        stepsSimulator?.makeStep(debug: true)
        makeStepButton.isEnabled = true
        stopStepsSimulationButton.isEnabled = true

        generatorsTable.reloadData()
    }

    @objc func stopStepsSimulation(_ sender: NSButton) {
        stepsSimulator = nil
        validateStepsSettings()

        generatorsTable.reloadData()
    }

    // MARK: - Validation

    @objc func textFieldDidChange(_ sender: TypedNSTextField) {
        validateAutoSettings()
        validateStepsSettings()
    }

    func mainSettingsAreValid() -> Bool {
        return sourcesAmountField.validateType() && bufferCapacityField.validateType() && handlersAmountField.validateType()
    }

    func validateAutoSettings() {
        let valid = mainSettingsAreValid() && autoSimulationIterationsField.validateType()
        startAutoSimulationButton.isEnabled = valid
    }

    func validateStepsSettings() {
        let valid = mainSettingsAreValid()
        makeStepButton.isEnabled = (stepsSimulator == nil && valid) || stepsSimulator != nil
        stopStepsSimulationButton.isEnabled = stepsSimulator != nil
    }
}

// MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        if tableView.identifier?.rawValue ?? "" != "generatorsTable" { return nil }
        if stepsSimulator == nil { return nil }
        if (stepsSimulator?.generators.count)! - 1 < row { return nil }

        switch tableColumn?.identifier.rawValue {
        case "numberColumn":
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "numberCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = stepsSimulator?.generators[row].priority ?? 0
            return cellView
        case "timeColumn":
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "timeCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = stepsSimulator?.generators[row].time ?? 0
            return cellView
        case "cooldownColumn":
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cooldownCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = stepsSimulator?.generators[row].cooldown ?? 0
            return cellView
        case "requestsCountColumn":
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "requestsCountCell")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = stepsSimulator?.generators[row].requestsCount ?? 0
            return cellView

        default:
            return nil
        }
    }
}

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {

        guard let stepsSimulator = self.stepsSimulator else {
            return 0
        }
        return stepsSimulator.generators.count
    }
}
