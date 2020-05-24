//
//  AppDelegate.swift
//  RestartX
//
//  Created by nekowen on 2020/05/24.
//  Copyright © 2020 nekowen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var waitForTerminateTimer: Timer?
    private var restarted: Bool = false
    
    @IBOutlet private var rootMenu: NSMenu!
    @IBOutlet private var restartXcodeMenu: NSMenuItem!
    @IBOutlet private var forceRestartXcodeMenu: NSMenuItem!
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusItem.button?.title = "X"
        self.statusItem.menu = rootMenu
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    @IBAction private func didTapRestartXcodeMenu(_ sender: Any) {
        self.restartApplication(force: false)
    }
    
    @IBAction private func didTapForceRestartXcodeMenu(_ sender: Any) {
        self.restartApplication(force: true)
    }
    
    @IBAction private func didTapQuitMenu(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    private func restartApplication(force: Bool, bundlerIdentifier: String = "com.apple.dt.Xcode", pollingInterval: TimeInterval = 0.5) {
        guard !restarted,
            let application = NSWorkspace.shared.runningApplication(bundleIdentifier: bundlerIdentifier),
            let bundleUrl = application.bundleURL else {
            return
        }
        
        self.restarted = true
        
        let resultTerminate: Bool
        if force {
            resultTerminate = application.forceTerminate()
        } else {
            resultTerminate = application.terminate()
        }
        
        guard resultTerminate else {
            self.restarted = false
            return
        }
        
        self.waitForTerminateTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            if application.isTerminated {
                self?.waitForTerminateTimer?.invalidate()
                self?.waitForTerminateTimer = nil
                _ = try? NSWorkspace.shared.launchApplication(at: bundleUrl, options: [], configuration: [:])
                
                self?.restarted = false
            }
        }
    }
}

extension AppDelegate: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem == self.restartXcodeMenu || menuItem == self.forceRestartXcodeMenu {
            return !self.restarted
        }
        return true
    }
}
