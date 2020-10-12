//
//  ViewController.swift
//  ServingSystem
//
//  Created by panandafog on 16.09.2020.
//  Copyright © 2020 panandafog. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate, NSTouchBarDelegate {

    // MARK: General properties

    var autoSimulator: Simulator?
    var stepsSimulator: Simulator?

    private let emptyString = " ––– "
    private let debug = false

    // MARK: Launch mode

    @IBOutlet private var modeSelector: NSPopUpButton!
    @IBOutlet private var modeTab: NSTabView!
    @IBOutlet private var modeSettingsTab: NSTabView!

    // MARK: General properties

    @IBOutlet private var generatorsAmountField: TypedNSTextField!
    @IBOutlet private var bufferCapacityField: TypedNSTextField!
    @IBOutlet private var processorsAmountField: TypedNSTextField!

    // MARK: Automatic mode properties

    @IBOutlet private var autoSimulationIterationsField: TypedNSTextField!

    @IBOutlet private var startAutoSimulationButton: NSButton!
    @IBOutlet private var stopAutoSimulationButton: NSButton!

    @IBOutlet private var autoSimulationProgressIndicator: NSProgressIndicator!

    @IBOutlet private var autoGeneratorsTable: NSTableView!
    @IBOutlet private var autoProcessorsTable: NSTableView!

    // MARK: Step by step mode properties

    @IBOutlet private var makeStepButton: NSButton!
    @IBOutlet private var stopStepsSimulationButton: NSButton!

    @IBOutlet private var stepsGeneratorsTable: NSTableView!
    @IBOutlet private var stepsProcessorsTable: NSTableView!
    @IBOutlet private var stepsBufferTable: NSTableView!
    @IBOutlet private var eventLog: NSTextView!

    @IBOutlet private var stepsSimulationProgressIndicator: NSProgressIndicator!

    // MARK: Touch bar properties

    @IBOutlet private var makeStepTouchBarButton: NSButton!
    @IBOutlet private var stopStepsSimulationTouchBarButton: NSButton!

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        startAutoSimulationButton.action = #selector(self.startAutoSimulation(_:))
        stopAutoSimulationButton.action = #selector(self.stopAutoSimulation(_:))

        makeStepButton.action = #selector(self.makeStep(_:))
        stopStepsSimulationButton.action = #selector(self.stopStepsSimulation(_:))

        makeStepTouchBarButton.action = makeStepButton.action
        stopStepsSimulationTouchBarButton.action = stopStepsSimulationButton.action

        generatorsAmountField.action = #selector(self.textFieldDidChange(_:))
        bufferCapacityField.action = #selector(self.textFieldDidChange(_:))
        processorsAmountField.action = #selector(self.textFieldDidChange(_:))

        autoSimulationIterationsField.action = #selector(self.textFieldDidChange(_:))

        generatorsAmountField.type = .positiveInt
        bufferCapacityField.type = .positiveInt
        processorsAmountField.type = .positiveInt

        processorsAmountField.delegate = self

        stepsGeneratorsTable.delegate = self
        stepsGeneratorsTable.dataSource = self
        stepsProcessorsTable.delegate = self
        stepsProcessorsTable.dataSource = self
        stepsBufferTable.delegate = self
        stepsBufferTable.dataSource = self

        autoGeneratorsTable.delegate = self
        autoGeneratorsTable.dataSource = self
        autoProcessorsTable.delegate = self
        autoProcessorsTable.dataSource = self
    }

    @IBAction private func modeChanged(_ sender: NSPopUpButton) {
        modeTab.selectTabViewItem(at: sender.indexOfSelectedItem)
        modeSettingsTab.selectTabViewItem(at: sender.indexOfSelectedItem)
    }

    // MARK: - Make touch bar
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        return touchBar
    }

    // MARK: - Automatic mode
    @objc func startAutoSimulation(_ sender: NSButton) {
        let generatorsCooldown = 1.0

        guard let generatorsCount = UInt(generatorsAmountField.stringValue),
              let processorsCount = UInt(processorsAmountField.stringValue),
              let bufferCapacity = UInt(bufferCapacityField.stringValue),
              let iterationsCount = UInt(autoSimulationIterationsField.stringValue) else {
            return
        }

        autoSimulator = Simulator(generatorsCount: generatorsCount,
                                  generatorsCooldown: generatorsCooldown,
                                  processorsCount: processorsCount,
                                  processorsCooldown: 1.0,
                                  bufferCapacity: bufferCapacity)

        startAutoSimulationButton.isEnabled = false
        stopAutoSimulationButton.isEnabled = true
        autoSimulationProgressIndicator.startAnimation(self)

        DispatchQueue.global(qos: .background).async {
            guard let simulator = self.autoSimulator else {
                return
            }
            simulator.startAutoSimulation(initialRequestsAmount: iterationsCount)
            DispatchQueue.main.async {
                self.startAutoSimulationButton.isEnabled = true
                self.stopAutoSimulationButton.isEnabled = false
                self.autoSimulationProgressIndicator.stopAnimation(self)

                self.autoProcessorsTable.reloadData()
                self.autoGeneratorsTable.reloadData()
            }
        }
    }

    @objc func stopAutoSimulation(_ sender: NSButton) {
        autoSimulator = nil
        startAutoSimulationButton.isEnabled = true
        stopAutoSimulationButton.isEnabled = false
        autoSimulationProgressIndicator.doubleValue = 0.0
        autoSimulationProgressIndicator.isHidden = true

        autoGeneratorsTable.reloadData()
        autoProcessorsTable.reloadData()
    }

    // MARK: - Step by step mode
    @objc func makeStep(_ sender: NSButton) {
        let generatorsCooldown = 1.0

        guard let generatorsCount = UInt(generatorsAmountField.stringValue),
              let processorsCount = UInt(processorsAmountField.stringValue),
              let bufferCapacity = UInt(bufferCapacityField.stringValue) else {
            return
        }

        makeStepButton.isEnabled = false
        stopStepsSimulationButton.isEnabled = false
        makeStepTouchBarButton.isEnabled = false
        stopStepsSimulationTouchBarButton.isEnabled = false
        stepsSimulationProgressIndicator.startAnimation(self)

        DispatchQueue.global(qos: .background).async {
            if self.stepsSimulator == nil {
                self.stepsSimulator = Simulator(generatorsCount: generatorsCount,
                                                generatorsCooldown: generatorsCooldown,
                                                processorsCount: processorsCount,
                                                processorsCooldown: 1.0,
                                                bufferCapacity: bufferCapacity)
            }
            self.stepsSimulator?.makeStep(debug: self.debug)
            DispatchQueue.main.async {
                self.makeStepButton.isEnabled = true
                self.stopStepsSimulationButton.isEnabled = true
                self.makeStepTouchBarButton.isEnabled = true
                self.stopStepsSimulationTouchBarButton.isEnabled = true
                self.stepsSimulationProgressIndicator.stopAnimation(self)

                self.stepsGeneratorsTable.reloadData()
                self.stepsProcessorsTable.reloadData()
                self.stepsBufferTable.reloadData()
                self.eventLog.string = self.stepsSimulator?.eventLog ?? ""
                let range = NSRange(location: self.eventLog.string.count, length: 0)
                self.eventLog.scrollRangeToVisible(range)
            }
        }
    }

    @objc func stopStepsSimulation(_ sender: NSButton) {
        stepsSimulator = nil
        validateStepsSettings()

        eventLog.string = ""
        stepsGeneratorsTable.reloadData()
        stepsProcessorsTable.reloadData()
        stepsBufferTable.reloadData()
    }

    // MARK: - Validation
    @objc func textFieldDidChange(_ sender: TypedNSTextField) {
        validateAutoSettings()
        validateStepsSettings()
    }

    func mainSettingsAreValid() -> Bool {
        generatorsAmountField.validateType()
            && bufferCapacityField.validateType()
            && processorsAmountField.validateType()
    }

    func validateAutoSettings() {
        let valid = mainSettingsAreValid() && autoSimulationIterationsField.validateType()
        startAutoSimulationButton.isEnabled = valid
    }

    func validateStepsSettings() {
        let valid = mainSettingsAreValid()
        makeStepButton.isEnabled = (stepsSimulator == nil && valid) || stepsSimulator != nil
        stopStepsSimulationButton.isEnabled = stepsSimulator != nil

        makeStepTouchBarButton.isEnabled = makeStepButton.isEnabled
        stopStepsSimulationTouchBarButton.isEnabled = stopStepsSimulationButton.isEnabled
    }
}

// MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate {

    func viewForStepsGeneratorsTable(columnId: String?, row: Int) -> NSView? {
        guard let stepsSimulator = self.stepsSimulator else {
            return nil
        }
        if (stepsSimulator.generators.count) - 1 < row {
            return nil
        }

        switch columnId {

        case "numberColumn":
            guard let cellView = stepsGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = stepsSimulator.generators[row].priority
            return cellView

        case "timeColumn":
            guard let cellView = stepsGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = stepsSimulator.generators[row].time
            return cellView

        case "cooldownColumn":
            guard let cellView = stepsGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cooldownCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = stepsSimulator.generators[row].cooldown
            return cellView

        case "requestsGeneratedColumn":
            guard let cellView = stepsGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestsGeneratedCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = stepsSimulator.generators[row].requestsCount
            return cellView

        case "requestsRejectedColumn":
            guard let cellView = stepsGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestsRejectedCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = stepsSimulator.getRejectedRequests()[row].count
            return cellView

        default:
            return nil
        }
    }

    func viewForStepsProcessorsTable(columnId: String?, row: Int) -> NSView? {
        guard let stepsSimulator = self.stepsSimulator else {
            return nil
        }
        if (stepsSimulator.processors.count) - 1 < row {
            return nil
        }

        switch columnId {

        case "numberColumn":
            guard let cellView = stepsProcessorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = Int(stepsSimulator.processors[row].number )
            return cellView

        case "timeColumn":
            guard let cellView = stepsProcessorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "timeCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = stepsSimulator.processors[row].time
            return cellView

        case "cooldownColumn":
            guard let cellView = stepsProcessorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cooldownCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = stepsSimulator.processors[row].cooldown
            return cellView

        case "currentRequestColumn":
            guard let cellView = stepsProcessorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "currentRequestCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = stepsSimulator.processors[row].request?.name ?? emptyString
            return cellView

        case "requestsProcessedColumn":
            guard let cellView = stepsProcessorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestsProcessedCell"),
                                                               owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = stepsSimulator.processors[row].requestsCount
            return cellView

        default:
            return nil
        }
    }

    func viewForStepsBufferTable(columnId: String?, row: Int) -> NSView? {
        guard let stepsSimulator = self.stepsSimulator else {
            return nil
        }
        if (stepsSimulator.buffer.queue.count) - 1 < row {
            return nil
        }

        switch columnId {

        case "numberColumn":
            guard let cellView = stepsBufferTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"),
                                                           owner: self) as? NSTableCellView else {
                return nil
            }
            cellView.textField?.integerValue = row + 1
            return cellView

        case "requestNameColumn":
            guard let cellView = stepsBufferTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestNameCell"),
                                                           owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = stepsSimulator.buffer.queue[row]?.name ?? emptyString
            return cellView

        case "requestCreatorColumn":
            guard let cellView = stepsBufferTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestCreatorCell"),
                                                           owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = stepsSimulator.buffer.queue[row]?.creatorNumber ?? 0
            return cellView

        case "requestCreationTimeColumn":
            guard let cellView = stepsBufferTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestCreationTimeCell"),
                                                           owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = stepsSimulator.buffer.queue[row]?.creationTime ?? 0
            return cellView

        default:
            return nil
        }
    }

    func viewForAutoGeneratorsTable(columnId: String?, row: Int) -> NSView? {
        guard let autoSimulator = self.autoSimulator else {
            return nil
        }

        if (autoSimulator.generators.count) - 1 < row {
            return nil
        }

        switch columnId {

        case "numberColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = autoSimulator.generators[row].priority
            return cellView

        case "requestsGeneratedColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "requestsGeneratedCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = autoSimulator.generators[row].requestsCount
            return cellView

        case "rejectProbabilityColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rejectProbabilityCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = Double(autoSimulator.getRejectedRequestsAmount(processorNumber: UInt(autoSimulator.generators[row].priority)))
                / Double( autoSimulator.generators[row].requestsCount)
            return cellView

        case "stayTimeColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "stayTimeCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = autoSimulator.getAverageRequestStayTime(generatorNumber: UInt(row + 1))
            return cellView

        case "waitingTimeColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "waitingTimeCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = autoSimulator.getAverageRequestWaitingTime(generatorNumber: UInt(row + 1))
            return cellView

        case "processingTimeColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "processingTimeCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = autoSimulator.getAverageRequestProcessingTime(generatorNumber: UInt(row + 1))
            return cellView

        case "waitingTimeDispersionColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "waitingTimeDispersionCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = 0.0
            return cellView

        case "processingTimeDispersionColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "processingTimeDispersionCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = 0.0
            return cellView

        default:
            return nil
        }
    }

    func viewForAutoProcessorsTable(columnId: String?, row: Int) -> NSView? {
        guard let autoSimulator = self.autoSimulator else {
            return nil
        }
        if (autoSimulator.processors.count) - 1 < row {
            return nil
        }

        switch columnId {

        case "numberColumn":
            guard let cellView = autoProcessorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = Int(autoSimulator.processors[row].number )
            return cellView

        case "usingRateColumn":
            guard let cellView = autoProcessorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "usingRateCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = autoSimulator.processors[row].bisyTime / autoSimulator.realisationTime
            return cellView

        default:
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier?.rawValue ?? "" == "stepsGeneratorsTable" {
            return viewForStepsGeneratorsTable(columnId: tableColumn?.identifier.rawValue, row: row)
        }

        if tableView.identifier?.rawValue ?? "" == "stepsProcessorsTable" {
            return viewForStepsProcessorsTable(columnId: tableColumn?.identifier.rawValue, row: row)
        }

        if tableView.identifier?.rawValue ?? "" == "stepsBufferTable" {
            return viewForStepsBufferTable(columnId: tableColumn?.identifier.rawValue, row: row)
        }

        if tableView.identifier?.rawValue ?? "" == "autoGeneratorsTable" {
            return viewForAutoGeneratorsTable(columnId: tableColumn?.identifier.rawValue, row: row)
        }

        if tableView.identifier?.rawValue ?? "" == "autoProcessorsTable" {
            return viewForAutoProcessorsTable(columnId: tableColumn?.identifier.rawValue, row: row)
        }

        return nil
    }
}

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {

        switch tableView.identifier?.rawValue ?? "" {

        case "stepsGeneratorsTable":
            guard let stepsSimulator = self.stepsSimulator else {
                return 0
            }
            return stepsSimulator.generators.count

        case "stepsProcessorsTable":
            guard let stepsSimulator = self.stepsSimulator else {
                return 0
            }
            return stepsSimulator.processors.count

        case "stepsBufferTable":
            guard let stepsSimulator = self.stepsSimulator else {
                return 0
            }
            return stepsSimulator.buffer.queue.count

        default:
            guard let autoSimulator = self.autoSimulator else {
                return 0
            }

            switch tableView.identifier?.rawValue ?? "" {

            case "autoGeneratorsTable":
                return autoSimulator.generators.count

            case "autoProcessorsTable":
                return autoSimulator.processors.count
            default:
                return 0
            }
        }
    }
}
