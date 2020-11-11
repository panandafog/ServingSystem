//
//  SettingsViewController.swift
//  ServingSystem
//
//  Created by panandafog on 13.10.2020.
//

import Cocoa

class SettingsViewController: NSViewController {

    // MARK: Generators settings

    @IBOutlet private var applyToAllGeneratorsButton: NSButton!
    @IBOutlet private var generatorsAmountField: NSTextField!

    @IBOutlet private var deleteGeneratorButton: NSButton!
    @IBOutlet private var addGeneratorButton: NSButton!

    @IBOutlet private var generatorsTable: NSTableView!

    // MARK: Processors settings

    @IBOutlet private var applyToAllProcessorsButton: NSButton!
    @IBOutlet private var processorsAmountField: NSTextField!

    @IBOutlet private var deleteProcessorButton: NSButton!
    @IBOutlet private var addProcessorButton: NSButton!

    @IBOutlet private var processorsTable: NSTableView!

    // MARK: - View Did Load

    override func viewDidLoad() {
        super.viewDidLoad()

        generatorsTable.delegate = self
        processorsTable.delegate = self
        generatorsTable.dataSource = self
        processorsTable.dataSource = self
    }

    // MARK: View Will Appear

    override func viewWillAppear() {
        super.viewWillAppear()

        generatorsTable.reloadData()
        processorsTable.reloadData()

        let properties = SimulationProperties.shared

        generatorsAmountField.stringValue = String(properties.generatorsAmount)
        processorsAmountField.stringValue = String(properties.processorsAmount)

        if properties.bufferCapacity > 1 {
            deleteGeneratorButton.isEnabled = true
        }
        if properties.processorsAmount > 1 {
            deleteProcessorButton.isEnabled = true
        }
    }

    // MARK: - Text fields actions

    @IBAction private func generatorsCooldownChanged(_ sender: NSTextField) {
        guard let row = sender.superview?.superview,
              let table = row.superview as? NSTableView else {
            return
        }

        let rowInd = table.row(for: sender)
        let newCooldown = sender.doubleValue
        var properties = SimulationProperties.shared.getGenerationProperties(index: rowInd)
        properties.cooldown = newCooldown
        SimulationProperties.shared.replaceGeneratorProperties(with: properties, at: UInt(rowInd))

        generatorsTable.reloadData()
    }

    @IBAction private func processorsMinCooldownChanged(_ sender: NSTextField) {
        guard let row = sender.superview?.superview,
              let table = row.superview as? NSTableView else {
            return
        }

        let rowInd = table.row(for: sender)
        let newCooldown = sender.doubleValue
        var properties = SimulationProperties.shared.getProcessingProperties(index: rowInd)
        properties.minTime = newCooldown
        SimulationProperties.shared.replaceProcessorProperties(with: properties, at: UInt(rowInd))

        processorsTable.reloadData()
    }
    
    @IBAction private func processorsMaxCooldownChanged(_ sender: NSTextField) {
        guard let row = sender.superview?.superview,
              let table = row.superview as? NSTableView else {
            return
        }

        let rowInd = table.row(for: sender)
        let newCooldown = sender.doubleValue
        var properties = SimulationProperties.shared.getProcessingProperties(index: rowInd)
        properties.maxTime = newCooldown
        SimulationProperties.shared.replaceProcessorProperties(with: properties, at: UInt(rowInd))

        processorsTable.reloadData()
    }

    // MARK: - Buttons actions

    @IBAction private func generatorsFunctionSelected(_ sender: NSComboBox) {
        guard let row = sender.superview?.superview,
              let table = row.superview as? NSTableView else {
            return
        }

        let rowInd = table.row(for: sender)
        var properties = SimulationProperties.shared.getGenerationProperties(index: rowInd)
        properties.function = GenerationFunction.allCases[sender.indexOfSelectedItem]
        SimulationProperties.shared.replaceGeneratorProperties(with: properties, at: UInt(rowInd))
    }

    @IBAction private func processorsFunctionSelected(_ sender: NSComboBox) {
        guard let row = sender.superview?.superview,
              let table = row.superview as? NSTableView else {
            return
        }

        let rowInd = table.row(for: sender)
        var properties = SimulationProperties.shared.getProcessingProperties(index: rowInd)
        properties.function = ProcessingFunction.allCases[sender.indexOfSelectedItem]
        SimulationProperties.shared.replaceProcessorProperties(with: properties, at: UInt(rowInd))
    }

    @IBAction private func addGeneratorRow(_ sender: NSButton) {
        SimulationProperties.shared.addGeneratorProperties()
        generatorsTable.reloadData()
        deleteGeneratorButton.isEnabled = true
    }

    @IBAction private func removeGeneratorRows(_ sender: NSButton) {
        let properties = SimulationProperties.shared

        if !generatorsTable.selectedRowIndexes.isEmpty {
            properties.removeGeneratorProperties(indices: generatorsTable.selectedRowIndexes)
        } else if properties.generatorsAmount > 1 {
            properties.removeGeneratorProperties(index: properties.generatorsAmount - 1)
        }
        if properties.generatorsAmount < 2 {
            deleteGeneratorButton.isEnabled = false
        }
        generatorsTable.reloadData()
    }

    @IBAction private func addProcessorRow(_ sender: NSButton) {
        SimulationProperties.shared.addProcessorProperties()
        processorsTable.reloadData()
        deleteProcessorButton.isEnabled = true
    }
    
    @IBAction private func removeProcessorRows(_ sender: NSButton) {
        let properties = SimulationProperties.shared
        if !processorsTable.selectedRowIndexes.isEmpty {
            properties.removeProcessorProperties(indices: processorsTable.selectedRowIndexes)
        } else if properties.processorsAmount > 1 {
            properties.removeProcessorProperties(index: properties.processorsAmount - 1)
        }
        if properties.processorsAmount < 2 {
            deleteProcessorButton.isEnabled = false
        }
        processorsTable.reloadData()
    }

    @IBAction private func applyToAllGenerators(_ sender: Any) {
        if generatorsTable.numberOfSelectedRows == 1 {
            SimulationProperties.shared.applyToAllGenerators(
                properties: SimulationProperties.shared.getGenerationProperties(index: generatorsTable.selectedRow))
        }
        generatorsTable.reloadData()
    }

    @IBAction private func applyToAllProcessors(_ sender: Any) {
        if processorsTable.numberOfSelectedRows == 1 {
            SimulationProperties.shared.applyToAllProcessors(
                properties: SimulationProperties.shared.getProcessingProperties(index: processorsTable.selectedRow))
        }
        processorsTable.reloadData()
    }

    @IBAction private func generatorsAmountFieldValueChanged(_ sender: NSTextField) {
        guard sender.integerValue > 0 else {
            return
        }
        SimulationProperties.shared.setGeneratorsAmount(UInt(sender.integerValue))
        generatorsTable.reloadData()
    }

    @IBAction private func processorsAmountFieldValueChanged(_ sender: NSTextField) {
        guard sender.integerValue > 0 else {
            return
        }
        SimulationProperties.shared.setProcessorsAmount(UInt(sender.integerValue))
        processorsTable.reloadData()
    }
}

// MARK: - NSTableViewDelegate

extension SettingsViewController: NSTableViewDelegate {

    func viewForGeneratorsTable(columnId: String?, row: Int) -> NSView? {
        let properties = SimulationProperties.shared

        if (properties.generatorsAmount) - 1 < row {
            return nil
        }

        switch columnId {

        case "numberColumn":
            guard let cellView = generatorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = row + 1
            return cellView

        case "cooldownColumn":
            guard let cellView = generatorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cooldownCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = properties.getGenerationProperties(index: row).cooldown
            return cellView

        case "functionColumn":
            guard let cellView = generatorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "functionCell"),
                                                          owner: self) as? GeneratorFunctionCellView else { return nil }
            cellView.selectFunction(properties.getGenerationProperties(index: row).function)
            return cellView

        case "deleteColumn":
            guard let cellView = generatorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = "<coming soon>"
            return cellView

        default:
            return nil
        }
    }

    func viewForProcessorsTable(columnId: String?, row: Int) -> NSView? {
        let properties = SimulationProperties.shared

        if (properties.processorsAmount) - 1 < row {
            return nil
        }

        switch columnId {

        case "numberColumn":
            guard let cellView = processorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "numberCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.integerValue = row + 1
            return cellView

        case "minCooldownColumn":
            guard let cellView = processorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "minCooldownCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = properties.getProcessingProperties(index: row).minTime
            return cellView

        case "maxCooldownColumn":
            guard let cellView = processorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "maxCooldownCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = properties.getProcessingProperties(index: row).maxTime
            return cellView

        case "functionColumn":
            guard let cellView = processorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "functionCell"),
                                                          owner: self) as? ProcessorFunctionCellView else { return nil }
            cellView.selectFunction(properties.getProcessingProperties(index: row).function)
            return cellView

        case "deleteColumn":
            guard let cellView = processorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "deleteCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = "<coming soon>"
            return cellView

        default:
            return nil
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView.identifier?.rawValue ?? "" == "settingsGeneratorsTable" {
            return viewForGeneratorsTable(columnId: tableColumn?.identifier.rawValue, row: row)
        }

        if tableView.identifier?.rawValue ?? "" == "settingsProcessorsTable" {
            return viewForProcessorsTable(columnId: tableColumn?.identifier.rawValue, row: row)
        }

        return nil
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        20
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView, let id = tableView.identifier?.rawValue else {
            return
        }

        if id  == "settingsGeneratorsTable" {
            if tableView.numberOfSelectedRows == 1 {
                applyToAllGeneratorsButton.isEnabled = true
                deleteGeneratorButton.isEnabled = !(tableView.selectedRow == 0 && SimulationProperties.shared.generatorsAmount == 1)
            } else if tableView.numberOfSelectedRows > 1 {
                applyToAllGeneratorsButton.isEnabled = false
                deleteGeneratorButton.isEnabled = (tableView.numberOfSelectedRows < SimulationProperties.shared.generatorsAmount)
            } else if tableView.numberOfSelectedRows == 0 {
                applyToAllGeneratorsButton.isEnabled = false
                deleteGeneratorButton.isEnabled = false
            }
        }

        if id  == "settingsProcessorsTable" {
            if tableView.numberOfSelectedRows == 1 {
                applyToAllProcessorsButton.isEnabled = true
                deleteProcessorButton.isEnabled = !(tableView.selectedRow == 0 && SimulationProperties.shared.processorsAmount == 1)
            } else if tableView.numberOfSelectedRows > 1 {
                applyToAllProcessorsButton.isEnabled = false
                deleteProcessorButton.isEnabled = (tableView.numberOfSelectedRows < SimulationProperties.shared.processorsAmount)
            } else if tableView.numberOfSelectedRows == 0 {
                applyToAllProcessorsButton.isEnabled = false
                deleteProcessorButton.isEnabled = false
            }
        }
    }
}

// MARK: - NSTableViewDataSource

extension SettingsViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView.identifier?.rawValue ?? "" {

        case "settingsGeneratorsTable":
            return Int(SimulationProperties.shared.generatorsAmount)

        case "settingsProcessorsTable":
            return Int(SimulationProperties.shared.processorsAmount)

        default:
            return 0
        }
    }
}
