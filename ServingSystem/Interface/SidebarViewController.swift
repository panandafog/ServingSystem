//
//  SidebarViewController.swift
//  ServingSystem
//
//  Created by panandafog on 13.10.2020.
//

import Cocoa

class SidebarViewController: NSViewController {

    var tabControllers = [NSButton]()

    var switchTab: ((UInt) -> Void)?

    @IBOutlet private var autoModeTabButton: NSButton!
    @IBOutlet private var stepsModeTabButton: NSButton!
    @IBOutlet private var settingsTabButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabControllers = [autoModeTabButton, stepsModeTabButton, settingsTabButton]

        disableTabSelectors(excluding: autoModeTabButton)
    }

    @IBAction private func switchTab(_ sender: NSButton) {
        switchTab(of: sender)
    }

    func disableTabSelectors(excluding sender: NSButton) {
        tabControllers.forEach({
            if $0 != sender {
                $0.state = .off
            } else {
                $0.state = .on
            }
        })
    }

    func switchTab(of sender: NSButton) {
        disableTabSelectors(excluding: sender)

        guard let switchTab = self.switchTab,
              let senderInd = tabControllers.firstIndex(of: sender) else {
            return
        }

        switchTab(UInt(senderInd))
    }
}
