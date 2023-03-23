//
//  SplitViewController.swift
//  ServingSystem
//
//  Created by panandafog on 13.10.2020.
//

import Cocoa

class SplitViewController: NSSplitViewController {
    
    let autoViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AutoViewController")
        as! AutoViewController
    let stepsViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "StepsViewController")
        as! StepsViewController
    let settingsViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "SettingsViewController")
        as! SettingsViewController
    let analysisViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AnalysisViewController")
        as! AnalysisViewController
    
    var sidebarViewController: SidebarViewController?
    
    var tabControllers = [NSViewController]()
    
    @IBOutlet private var sidebarItem: NSSplitViewItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabControllers = [
            stepsViewController,
            autoViewController,
            settingsViewController,
            analysisViewController
        ]
        
        sidebarViewController = self.children[0] as? SidebarViewController
        sidebarViewController?.switchTab = self.switchTab(_:)
        
        self.addChild(self.stepsViewController)
    }
    
    func switchTab(_ number: Int) {
        if number < tabControllers.count {
            removeChild(at: self.children.count - 1)
            addChild(tabControllers[number])
        }
    }
}
