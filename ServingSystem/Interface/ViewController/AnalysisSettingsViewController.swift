//
//  AnalysisSettingsViewController.swift
//  ServingSystem
//
//  Created by panandafog on 29.10.2020.
//

import Cocoa

class AnalysisSettingsViewController: NSViewController {
    
    var analyser = Analyser()
    
    @IBAction private func startButtonPressed(_ sender: Any) {
        analyser.start()
    }
}
