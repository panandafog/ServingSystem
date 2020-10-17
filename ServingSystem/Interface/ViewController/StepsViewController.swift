//
//  StepsViewController.swift
//  ServingSystem
//
//  Created by panandafog on 13.10.2020.
//

import Cocoa

class StepsViewController: NSViewController, NSTextFieldDelegate, NSTouchBarDelegate {

    // MARK: General properties

    var stepsSimulator: Simulator?

    private let emptyString = " ––– "
    private let debug = false

    // MARK: Text fields

    @IBOutlet private var generatorsAmountField: TypedNSTextField!
    @IBOutlet private var bufferCapacityField: TypedNSTextField!
    @IBOutlet private var processorsAmountField: TypedNSTextField!

    // MARK: Buttons

    @IBOutlet private var makeStepButton: NSButton!
    @IBOutlet private var stopStepsSimulationButton: NSButton!

    // MARK: Tables

    @IBOutlet private var stepsGeneratorsTable: NSTableView!
    @IBOutlet private var stepsProcessorsTable: NSTableView!
    @IBOutlet private var stepsBufferTable: NSTableView!

    // MARK: Other

    @IBOutlet private var eventLog: NSTextView!
    @IBOutlet private var stepsSimulationProgressIndicator: NSProgressIndicator!

    // MARK: Touch bar properties

    @IBOutlet private var makeStepTouchBarButton: NSButton!
    @IBOutlet private var stopStepsSimulationTouchBarButton: NSButton!

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        makeStepTouchBarButton.action = makeStepButton.action
        stopStepsSimulationTouchBarButton.action = stopStepsSimulationButton.action

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
    }

    @IBAction private func textFieldValueChanged(_ sender: Any) {
        validateStepsSettings()
    }

    // MARK: - Step by step mode

    @IBAction private func makeStep(_ sender: Any) {
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

    @IBAction private func stopStepsSimulation(_ sender: Any) {
        stepsSimulator = nil
        validateStepsSettings()

        eventLog.string = ""
        stepsGeneratorsTable.reloadData()
        stepsProcessorsTable.reloadData()
        stepsBufferTable.reloadData()
    }

    // MARK: - Make touch bar
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        return touchBar
    }

    // MARK: - Validation
    func mainSettingsAreValid() -> Bool {
        generatorsAmountField.validateType()
            && bufferCapacityField.validateType()
            && processorsAmountField.validateType()
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
extension StepsViewController: NSTableViewDelegate {

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

        return nil
    }
}

// MARK: - NSTableViewDataSource
extension StepsViewController: NSTableViewDataSource {

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
            return 0
        }
    }
}