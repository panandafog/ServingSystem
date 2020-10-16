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
    @IBOutlet private var generatorsAmountField: TypedNSTextField!

    @IBOutlet private var generatorsTable: NSTableView!

    // MARK: Processors settings

    @IBOutlet private var applyToAllProcessorsButton: NSButton!
    @IBOutlet private var processorsAmountField: TypedNSTextField!

    @IBOutlet private var processorsTable: NSTableView!

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        generatorsTable.delegate = self
        processorsTable.delegate = self
        generatorsTable.dataSource = self
        processorsTable.dataSource = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        generatorsTable.reloadData()
        processorsTable.reloadData()
    }

    // MARK: - Radio buttons actions

    @IBAction private func applyToAllGenerators(_ sender: Any) {

        generatorsTable.reloadData()
    }

    @IBAction private func applyToAllProcessors(_ sender: Any) {

        processorsTable.reloadData()
    }

    // MARK: - Text fields actions
    @IBAction private func generatorsCooldownChanged(_ sender: NSTextField) {
        guard let row = sender.superview?.superview,
              let table = row.superview as? NSTableView else {
            return
        }

        let rowInd = table.row(for: sender)
        let newCooldown = sender.doubleValue
        var properties = SimulationProperties.shared.currentGenerationProperties[rowInd]
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
        var properties = SimulationProperties.shared.currentProcessingProperties[rowInd]
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
        var properties = SimulationProperties.shared.currentProcessingProperties[rowInd]
        properties.maxTime = newCooldown
        SimulationProperties.shared.replaceProcessorProperties(with: properties, at: UInt(rowInd))

        processorsTable.reloadData()
    }

    @IBAction private func generatorsAmountFieldValueChanged(_ sender: Any) {
    }

    @IBAction private func processorsAmountFieldValueChanged(_ sender: Any) {
    }
}

// MARK: - NSTableViewDelegate
extension SettingsViewController: NSTableViewDelegate {

    func viewForGeneratorsTable(columnId: String?, row: Int) -> NSView? {
        let properties = SimulationProperties.shared

        if (properties.currentGenerationProperties.count) - 1 < row {
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
            cellView.textField?.doubleValue = properties.currentGenerationProperties[row].cooldown
            return cellView

        case "functionColumn":
            guard let cellView = generatorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "functionCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = "<coming soon>"
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

        if (properties.currentProcessingProperties.count) - 1 < row {
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
            cellView.textField?.doubleValue = properties.currentProcessingProperties[row].minTime
            return cellView

        case "maxCooldownColumn":
            guard let cellView = processorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "maxCooldownCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.doubleValue = properties.currentProcessingProperties[row].maxTime
            return cellView

        case "functionColumn":
            guard let cellView = processorsTable.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "functionCell"),
                                                          owner: self) as? NSTableCellView else { return nil }
            cellView.textField?.stringValue = "<coming soon>"
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
