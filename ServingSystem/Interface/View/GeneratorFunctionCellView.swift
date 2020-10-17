//
//  GeneratorFunctionCellView.swift
//  ServingSystem
//
//  Created by panandafog on 17.10.2020.
//

import Cocoa

class GeneratorFunctionCellView: NSTableCellView {

    @IBOutlet private var functionTypeComboBox: NSComboBox!

    override func viewWillDraw() {
        super.viewWillDraw()
        functionTypeComboBox.usesDataSource = true
        functionTypeComboBox.delegate = self
        functionTypeComboBox.dataSource = self

        functionTypeComboBox.reloadData()
    }

    func selectFunction(_ function: GenerationFunction) {
        viewWillDraw()
        functionTypeComboBox.selectItem(at: GenerationFunction.allCases.firstIndex(of: function) ?? 0)
    }
}
// MARK: - NSComboBoxDelegate
extension GeneratorFunctionCellView: NSComboBoxDelegate {

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        GenerationFunction.allCases[index].rawValue
    }
}

// MARK: - NSComboBoxDataSource
extension GeneratorFunctionCellView: NSComboBoxDataSource {

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        GenerationFunction.allCases.count
    }
}
