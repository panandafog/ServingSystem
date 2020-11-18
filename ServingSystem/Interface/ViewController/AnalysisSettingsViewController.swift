//
//  AnalysisSettingsViewController.swift
//  ServingSystem
//
//  Created by panandafog on 29.10.2020.
//

import Cocoa

class AnalysisSettingsViewController: NSViewController {
    
    var analyser = Analyser()
    
    var onStartAction: (() -> Void)?
    
    @IBOutlet private var modeSegmentedControl: NSSegmentedControl!
    
    @IBOutlet private var fromField: NSTextField!
    @IBOutlet private var toField: NSTextField!
    
    @IBOutlet private var analyseButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modeSegmentedControl.selectSegment(withTag: analyser.mode.hashValue)
        setupTextFields()
        validateSettings()
    }
    
    @IBAction private func modeChanged(_ sender: NSSegmentedControl) {
        let mode = Analyser.Mode.allCases[sender.indexOfSelectedItem]
        analyser.updateValuesFor(mode: mode)
        
        fromField.integerValue = analyser.minValue
        toField.integerValue = analyser.maxValue
    }
    
    @IBAction private func startButtonPressed(_ sender: Any) {
        selectAllText()
        
        analyser.start()
        self.view.window?.close()
        guard let onStartAction = self.onStartAction else {
            return
        }
        onStartAction()
    }
    
    @IBAction private func textValueChanged(_ sender: NSTextField) {
        validateSettings()
    }
    
    private func setupTextFields() {
        fromField.stringValue = String(analyser.minValue)
        toField.stringValue = String(analyser.maxValue)
    }
    
    private func validateSettings() {
        analyser.minValue = fromField.integerValue
        analyser.maxValue = toField.integerValue
        
        analyseButton.isEnabled = analyser.minValue < analyser.maxValue
    }
    
    private func selectAllText() {
        toField.selectText(self)
        fromField.selectText(self)
    }
}
