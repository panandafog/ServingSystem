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
    @IBOutlet private var poissonDistributionCheckbox: NSButton!
    @IBOutlet private var generatorsAmountField: TypedNSTextField!

    @IBOutlet private var generatorsTable: NSTableView!

    // MARK: Processors settings

    @IBOutlet private var applyToAllProcessorsButton: NSButton!
    @IBOutlet private var exponentCheckbox: NSButton!
    @IBOutlet private var processorsAmountField: TypedNSTextField!

    @IBOutlet private var processorsTable: NSTableView!

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Radio buttons actions

    @IBAction private func applyToAllGenerators(_ sender: Any) {
    }

    @IBAction private func applyToAllProcessors(_ sender: Any) {
    }

    // MARK: - Text fields actions

    @IBAction private func generatorsAmountFieldValueChanged(_ sender: Any) {
    }

    @IBAction private func processorsAmountFieldValueChanged(_ sender: Any) {
    }
}
