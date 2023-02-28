//
//  AutoViewController.swift
//  ServingSystem
//
//  Created by panandafog on 13.10.2020.
//

import Cocoa

class AutoViewController: SavingTextViewController, NSTouchBarDelegate {

    // MARK: General properties

    var autoSimulator: Simulator?
    var simulationThread: SimulationThread?

    private let emptyString = " ––– "
    private let debug = false

    // MARK: Text fields

    @IBOutlet private var generatorsAmountField: FocusAwareTextField!
    @IBOutlet private var bufferCapacityField: FocusAwareTextField!
    @IBOutlet private var processorsAmountField: FocusAwareTextField!
    @IBOutlet private var iterationsCountField: FocusAwareTextField!

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

        autoGeneratorsTable.delegate = self
        autoGeneratorsTable.dataSource = self
        autoProcessorsTable.delegate = self
        autoProcessorsTable.dataSource = self
        
        setupTextDield(iterationsCountField)
        setupTextDield(bufferCapacityField)
        setupTextDield(generatorsAmountField)
        setupTextDield(processorsAmountField)
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
        saveText()
        
        autoSimulator = Simulator()

        startAutoSimulationButton.isEnabled = false
        stopAutoSimulationButton.isEnabled = true

        startAutoSimulationTouchBarButton.isEnabled = false
        stopAutoSimulationTouchBarButton.isEnabled = true

        autoSimulationProgressIndicator.startAnimation(self)

        guard let simulator = self.autoSimulator else {
            return
        }
        simulationThread = SimulationThread(simulator: simulator, completion: ({
            DispatchQueue.main.async {
                self.startAutoSimulationButton.isEnabled = true
                self.stopAutoSimulationButton.isEnabled = false

                self.startAutoSimulationTouchBarButton.isEnabled = true
                self.stopAutoSimulationTouchBarButton.isEnabled = false

                self.autoSimulationProgressIndicator.stopAnimation(self)

                self.autoProcessorsTable.reloadData()
                self.autoGeneratorsTable.reloadData()
            }
        }))
        simulationThread?.start()
    }

    @IBAction private func stopAutoSimulation(_ sender: Any) {
        simulationThread?.cancel()
        autoSimulator = nil

        stopAutoSimulationButton.isEnabled = false
        stopAutoSimulationTouchBarButton.isEnabled = false
    }

    // MARK: - Validation

    func validateSettings() {
        var valid = true
        let textFields = [generatorsAmountField, processorsAmountField, bufferCapacityField, iterationsCountField]
        for textField in textFields where textField?.integerValue == nil {
            valid = false
            break
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
            return numberCell(row: row, autoSimulator: autoSimulator)

        case "requestsGeneratedColumn":
            return requestsGeneratedCell(row: row, autoSimulator: autoSimulator)

        case "rejectProbabilityColumn":
            return rejectProbabilityCell(row: row, autoSimulator: autoSimulator)

        case "stayTimeColumn":
            return stayTimeCell(row: row, autoSimulator: autoSimulator)

        case "waitingTimeColumn":
            return waitingTimeCell(row: row, autoSimulator: autoSimulator)

        case "processingTimeColumn":
            return processingTimeCell(row: row, autoSimulator: autoSimulator)

        case "waitingTimeDispersionColumn":
            return waitingTimeDispersionCell(row: row, autoSimulator: autoSimulator)

        case "processingTimeDispersionColumn":
            return processingTimeDispersionCell(row: row, autoSimulator: autoSimulator)

        default:
            return nil
        }
    }
    
    func numberCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "numberCell")
        cellView?.textField?.integerValue = autoSimulator.generators[row].priority
        return cellView
    }
    
    func requestsGeneratedCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "requestsGeneratedCell")
        cellView?.textField?.integerValue = autoSimulator.generators[row].requestsCount
        return cellView
    }
    
    func rejectProbabilityCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "rejectProbabilityCell")
        cellView?.textField?.doubleValue = Double(
            autoSimulator.getRejectedRequestsAmount(
                creatorNumber: UInt(autoSimulator.generators[row].priority)
            )
        ) / Double(autoSimulator.generators[row].requestsCount)
        return cellView
    }
    
    func stayTimeCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "stayTimeCell")
        let time = autoSimulator.getAverageRequestStayTime(generatorNumber: UInt(row + 1))
        if time.isNaN {
            cellView?.textField?.stringValue = emptyString
        } else {
            cellView?.textField?.doubleValue = time
        }
        return cellView
    }
    
    func waitingTimeCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "waitingTimeCell")
        let time = autoSimulator.getAverageRequestWaitingTime(generatorNumber: UInt(row + 1))
        if time.isNaN {
            cellView?.textField?.stringValue = emptyString
        } else {
            cellView?.textField?.doubleValue = time
        }
        return cellView
    }
    
    func processingTimeCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "processingTimeCell")
        let time = autoSimulator.getAverageRequestProcessingTime(generatorNumber: UInt(row + 1))
        if time.isNaN {
            cellView?.textField?.stringValue = emptyString
        } else {
            cellView?.textField?.doubleValue = time
        }
        return cellView
    }
    
    func waitingTimeDispersionCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "waitingTimeDispersionCell")
        let requests = autoSimulator.getCompletedRequests(from: UInt(row + 1))
        var waitingTime = [Double]()

        for request in requests where request.pickTime != nil {
            waitingTime.append(request.pickTime! - request.creationTime)
        }

        cellView?.textField?.doubleValue = Maths.dispersion(of: waitingTime)
        return cellView
    }
    
    func processingTimeDispersionCell(row: Int, autoSimulator: Simulator) -> NSTableCellView? {
        let cellView = makeAutoGeneratorsCell(id: "processingTimeDispersionCell")
        let requests = autoSimulator.getCompletedRequests(from: UInt(row + 1))
        var processingTime = [Double]()

        for request in requests where (request.pickTime != nil && request.completionTime != nil) {
            processingTime.append(request.completionTime! - request.pickTime!)
        }

        cellView?.textField?.doubleValue = Maths.dispersion(of: processingTime)
        return cellView
    }
    
    func makeAutoGeneratorsCell(id: String) -> NSTableCellView? {
        autoGeneratorsTable.makeView(
            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id),
            owner: self
        ) as? NSTableCellView
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
            cellView.textField?.doubleValue = autoSimulator.getProcessorUsingRate(index: UInt(row))
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
