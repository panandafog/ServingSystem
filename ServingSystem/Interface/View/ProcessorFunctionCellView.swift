//
//  ProcessorFunctionCellView.swift
//  ServingSystem
//
//  Created by panandafog on 17.10.2020.
//

import Cocoa

class ProcessorFunctionCellView: NSTableCellView {

    @IBOutlet private var functionTypeComboBox: NSComboBox!

    override func viewWillDraw() {
        super.viewWillDraw()
        functionTypeComboBox.usesDataSource = true
        functionTypeComboBox.delegate = self
        functionTypeComboBox.dataSource = self

        functionTypeComboBox.reloadData()
    }

    func selectFunction(_ function: ProcessingFunction) {
        viewWillDraw()
        functionTypeComboBox.selectItem(at: ProcessingFunction.allCases.firstIndex(of: function) ?? 0)
    }
}

// MARK: - NSComboBoxDelegate

extension ProcessorFunctionCellView: NSComboBoxDelegate {

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        ProcessingFunction.allCases[index].rawValue
    }
}

// MARK: - NSComboBoxDataSource

extension ProcessorFunctionCellView: NSComboBoxDataSource {

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        ProcessingFunction.allCases.count
    }
}
