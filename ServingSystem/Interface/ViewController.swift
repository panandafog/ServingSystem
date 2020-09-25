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

    // MARK: General properties

    @IBOutlet var generatorsAmountField: TypedNSTextField!
    @IBOutlet var bufferCapacityField: TypedNSTextField!
    @IBOutlet var processorsAmountField: TypedNSTextField!

    // MARK: Automatic mode properties

    @IBOutlet var autoSimulationIterationsField: TypedNSTextField!

    @IBOutlet var startAutoSimulationButton: NSButton!
    @IBOutlet var stopAutoSimulationButton: NSButton!

    @IBOutlet var autoSimulationProgressIndicator: NSProgressIndicator!

    // MARK: Step by step mode properties

    @IBOutlet var makeStepButton: NSButton!
    @IBOutlet var stopStepsSimulationButton: NSButton!

    @IBOutlet var generatorsTable: NSTableView!
    @IBOutlet var processorsTable: NSTableView!
    @IBOutlet var bufferTable: NSTableView!
    @IBOutlet var eventLog: NSTextView!

    @IBOutlet var stepsSimulationProgressIndicator: NSProgressIndicator!

    var autoSimulator: Simulator?
    var stepsSimulator: Simulator?

    private let emptyString = " ––– "
    private let debug = false

    override func viewDidLoad() {
        super.viewDidLoad()

        startAutoSimulationButton.action = #selector(self.startAutoSimulation(_:))
        stopAutoSimulationButton.action = #selector(self.stopAutoSimulation(_:))

        makeStepButton.action = #selector(self.makeStep(_:))
        stopStepsSimulationButton.action = #selector(self.stopStepsSimulation(_:))

        generatorsAmountField.action = #selector(self.textFieldDidChange(_:))
        bufferCapacityField.action = #selector(self.textFieldDidChange(_:))
        processorsAmountField.action = #selector(self.textFieldDidChange(_:))

        autoSimulationIterationsField.action = #selector(self.textFieldDidChange(_:))

        generatorsAmountField.type = .positiveInt
        bufferCapacityField.type = .positiveInt
        processorsAmountField.type = .positiveInt

        processorsAmountField.delegate = self
        generatorsTable.delegate = self
        generatorsTable.dataSource = self
        processorsTable.delegate = self
        processorsTable.dataSource = self
        bufferTable.delegate = self
        bufferTable.dataSource = self

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

        guard let generatorsCount = UInt(generatorsAmountField.stringValue), let processorsCount = UInt(processorsAmountField.stringValue), let bufferCapacity = UInt(bufferCapacityField.stringValue), let iterationsCount = UInt(autoSimulationIterationsField.stringValue) else {
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
                self.autoSimulator?.makeStep(debug: false)
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

        guard let generatorsCount = UInt(generatorsAmountField.stringValue), let processorsCount = UInt(processorsAmountField.stringValue), let bufferCapacity = UInt(bufferCapacityField.stringValue) else {
            return
        }

        if stepsSimulator == nil {
            stepsSimulator = Simulator(generatorsCount: generatorsCount, generatorsCooldown: generatorsCooldown, processorsCount: processorsCount, processorsCooldown: 1.0, bufferCapacity: bufferCapacity)
        }

        makeStepButton.isEnabled = false
        stopStepsSimulationButton.isEnabled = false
        stepsSimulationProgressIndicator.startAnimation(self)

        DispatchQueue.global(qos: .background).async {
            self.stepsSimulator?.makeStep(debug: self.debug)
            DispatchQueue.main.async {
                self.makeStepButton.isEnabled = true
                self.stopStepsSimulationButton.isEnabled = true
                self.stepsSimulationProgressIndicator.stopAnimation(self)

                self.generatorsTable.reloadData()
                self.processorsTable.reloadData()
                self.bufferTable.reloadData()
                self.eventLog.string = self.stepsSimulator?.eventLog ?? ""
                let range = NSMakeRange(self.eventLog.string.count, 0)
                self.eventLog.scrollRangeToVisible(range)
            }
        }
    }

    @objc func stopStepsSimulation(_ sender: NSButton) {
        stepsSimulator = nil
        validateStepsSettings()

        eventLog.string = ""
        generatorsTable.reloadData()
        processorsTable.reloadData()
        bufferTable.reloadData()
    }

    // MARK: - Validation

    @objc func textFieldDidChange(_ sender: TypedNSTextField) {
        validateAutoSettings()
        validateStepsSettings()
    }

    func mainSettingsAreValid() -> Bool {
        return generatorsAmountField.validateType() && bufferCapacityField.validateType() && processorsAmountField.validateType()
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

        if tableView.identifier?.rawValue ?? "" == "generatorsTable" {
            if stepsSimulator == nil { return nil }
            if (stepsSimulator?.generators.count)! - 1 < row { return nil }

            switch tableColumn?.identifier.rawValue {

            case "numberColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = stepsSimulator?.generators[row].priority ?? 0
                return cellView

            case "timeColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.doubleValue = stepsSimulator?.generators[row].time ?? 0
                return cellView

            case "cooldownColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cooldownCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.doubleValue = stepsSimulator?.generators[row].cooldown ?? 0
                return cellView

            case "requestsGeneratedColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestsGeneratedCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = stepsSimulator?.generators[row].requestsCount ?? 0
                return cellView

            case "requestsRejectedColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestsRejectedCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = stepsSimulator?.getRejectedRequests()[row].count ?? 0
                return cellView

            default:
                return nil
            }
        }

        if tableView.identifier?.rawValue ?? "" == "processorsTable" {
            if stepsSimulator == nil { return nil }
            if (stepsSimulator?.processors.count)! - 1 < row { return nil }

            switch tableColumn?.identifier.rawValue {

            case "numberColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = Int(stepsSimulator?.processors[row].number ?? 0)
                return cellView

            case "timeColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.doubleValue = stepsSimulator?.processors[row].time ?? 0
                return cellView

            case "cooldownColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cooldownCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.doubleValue = stepsSimulator?.processors[row].cooldown ?? 0
                return cellView

            case "currentRequestColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "currentRequestCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = stepsSimulator?.processors[row].request?.name ?? emptyString
                return cellView

            case "requestsProcessedColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestsProcessedCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = stepsSimulator?.processors[row].requestsCount ?? 0
                return cellView

            default:
                return nil
            }
        }

        if tableView.identifier?.rawValue ?? "" == "bufferTable" {
            if stepsSimulator == nil { return nil }
            if (stepsSimulator?.buffer.queue.count)! - 1 < row { return nil }

            switch tableColumn?.identifier.rawValue {

            case "numberColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = row + 1
                return cellView

            case "requestNameColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestNameCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = stepsSimulator?.buffer.queue[row]?.name ?? emptyString
                return cellView

            case "requestCreatorColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestCreatorCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.integerValue = stepsSimulator?.buffer.queue[row]?.creatorNumber ?? 0
                return cellView

            case "requestCreationTimeColumn":
                guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestCreationTimeCell"), owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.doubleValue = stepsSimulator?.buffer.queue[row]?.creationTime ?? 0
                return cellView

            default:
                return nil
            }
        }

        return nil
    }
}

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {

        guard let stepsSimulator = self.stepsSimulator else {
            return 0
        }

        switch tableView.identifier?.rawValue ?? "" {

        case "generatorsTable":
            return stepsSimulator.generators.count

        case "processorsTable":
            return stepsSimulator.processors.count

        case "bufferTable":
            return stepsSimulator.buffer.queue.count

        default:
            return 0
        }
    }
}
