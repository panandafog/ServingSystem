//
//  AutoViewController.swift
//  ServingSystem
//
//  Created by panandafog on 13.10.2020.
//

import Cocoa

class AutoViewController: NSViewController, NSTextFieldDelegate, NSTouchBarDelegate {

    // MARK: General properties

    var autoSimulator: Simulator?

    private let emptyString = " ––– "
    private let debug = false

    // MARK: Text fields

    @IBOutlet private var generatorsAmountField: NSTextField!
    @IBOutlet private var bufferCapacityField: NSTextField!
    @IBOutlet private var processorsAmountField: NSTextField!
    @IBOutlet private var iterationsCountField: NSTextField!

    // MARK: Buttons

    @IBOutlet private var startAutoSimulationButton: NSButton!
    @IBOutlet private var stopAutoSimulationButton: NSButton!

    @IBOutlet private var autoSimulationProgressIndicator: NSProgressIndicator!

    // MARK: Tables

    @IBOutlet private var autoGeneratorsTable: NSTableView!
    @IBOutlet private var autoProcessorsTable: NSTableView!

    // MARK: Touch bar properties

    @IBOutlet private var startAutoSimulationTouchBarButton: NSButton!
    @IBOutlet private var stopAutoSimulationTouchBarButton: NSButton!

    // MARK: - View did load

    override func viewDidLoad() {
        super.viewDidLoad()

        processorsAmountField.delegate = self

        autoGeneratorsTable.delegate = self
        autoGeneratorsTable.dataSource = self
        autoProcessorsTable.delegate = self
        autoProcessorsTable.dataSource = self
    }

    // MARK: - View will appear

    override func viewWillAppear() {
        super.viewWillAppear()

        let properties = SimulationProperties.shared

        generatorsAmountField.stringValue = String(properties.generatorsAmount)
        processorsAmountField.stringValue = String(properties.processorsAmount)
        bufferCapacityField.stringValue = String(properties.bufferCapacity)
        iterationsCountField.stringValue = String(properties.iterationsCount)

        validateSettings()
    }

    // MARK: - Text Fields

    @IBAction private func iterationsCountTextFieldValueChanged(_ sender: NSTextField) {
        guard sender.integerValue > 0 else {
            return
        }
        SimulationProperties.shared.iterationsCount = UInt(sender.integerValue)
        validateSettings()
    }

    @IBAction private func generatorsAmountFieldValueChanged(_ sender: NSTextField) {
        guard sender.integerValue > 0 else {
            return
        }
        SimulationProperties.shared.setGeneratorsAmount(UInt(sender.integerValue))
        validateSettings()
    }

    @IBAction private func processorsAmountFieldValueChanged(_ sender: NSTextField) {
        guard sender.integerValue > 0 else {
            return
        }
        SimulationProperties.shared.setProcessorsAmount(UInt(sender.integerValue))
        validateSettings()
    }

    @IBAction private func bufferCapacityFieldValueChanged(_ sender: NSTextField) {
        guard sender.integerValue > 0 else {
            return
        }
        SimulationProperties.shared.bufferCapacity = UInt(sender.integerValue)
        validateSettings()
    }

    // MARK: - Automatic mode

    @IBAction private func startAutoSimulation(_ sender: Any) {
        let generatorsCooldown = 1.0

        guard let generatorsCount = UInt(generatorsAmountField.stringValue),
              let processorsCount = UInt(processorsAmountField.stringValue),
              let bufferCapacity = UInt(bufferCapacityField.stringValue),
              let iterationsCount = UInt(iterationsCountField.stringValue) else {
            return
        }

        autoSimulator = Simulator(generatorsCount: generatorsCount,
                                  generatorsCooldown: generatorsCooldown,
                                  processorsCount: processorsCount,
                                  processorsCooldown: 1.0,
                                  bufferCapacity: bufferCapacity)

        startAutoSimulationButton.isEnabled = false
        stopAutoSimulationButton.isEnabled = true

        startAutoSimulationTouchBarButton.isEnabled = false
        stopAutoSimulationTouchBarButton.isEnabled = true

        autoSimulationProgressIndicator.startAnimation(self)

        DispatchQueue.global(qos: .background).async {
            guard let simulator = self.autoSimulator else {
                return
            }
            simulator.startAutoSimulation(initialRequestsAmount: iterationsCount)
            DispatchQueue.main.async {
                self.startAutoSimulationButton.isEnabled = true
                self.stopAutoSimulationButton.isEnabled = false

                self.startAutoSimulationTouchBarButton.isEnabled = true
                self.stopAutoSimulationTouchBarButton.isEnabled = false

                self.autoSimulationProgressIndicator.stopAnimation(self)

                self.autoProcessorsTable.reloadData()
                self.autoGeneratorsTable.reloadData()
            }
        }
    }

    @IBAction private func stopAutoSimulation(_ sender: Any) {
        autoSimulator = nil
        startAutoSimulationButton.isEnabled = true
        stopAutoSimulationButton.isEnabled = false

        startAutoSimulationTouchBarButton.isEnabled = true
        stopAutoSimulationTouchBarButton.isEnabled = false

        autoGeneratorsTable.reloadData()
        autoProcessorsTable.reloadData()
    }

    // MARK: - Make touch bar

    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        return touchBar
    }

    // MARK: - Validation

    func validateSettings() {
        var valid = true
        let textFields = [generatorsAmountField, processorsAmountField, bufferCapacityField, iterationsCountField]
        for textField in textFields {
            if textField?.integerValue == nil {
                valid = false
                break
            }
        }
        startAutoSimulationButton.isEnabled = valid
        startAutoSimulationTouchBarButton.isEnabled = valid
    }
}

// MARK: - NSTableViewDelegate

extension AutoViewController: NSTableViewDelegate {

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
            cellView.textField?.doubleValue = Double(autoSimulator.getRejectedRequestsAmount(creatorNumber: UInt(autoSimulator.generators[row].priority)))
                / Double(autoSimulator.generators[row].requestsCount)
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
            let requests = autoSimulator.getCompletedRequests(from: UInt(row + 1))
            var waitingTime = [Double]()

            for request in requests where request.pickTime != nil {
                waitingTime.append(request.pickTime! - request.creationTime)
            }

            cellView.textField?.doubleValue = Maths.dispersion(of: waitingTime)
            return cellView

        case "processingTimeDispersionColumn":
            guard let cellView = autoGeneratorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "processingTimeDispersionCell"),
                                                              owner: self) as? NSTableCellView else { return nil }
            let requests = autoSimulator.getCompletedRequests(from: UInt(row + 1))
            var processingTime = [Double]()

            for request in requests where (request.pickTime != nil && request.completionTime != nil) {
                processingTime.append(request.completionTime! - request.pickTime!)
            }

            cellView.textField?.doubleValue = Maths.dispersion(of: processingTime)
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

extension AutoViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {

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
