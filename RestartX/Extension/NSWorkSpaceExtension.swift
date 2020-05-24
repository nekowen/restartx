//
//  NSWorkSpaceExtension.swift
//  RestartX
//
//  Created by nekowen on 2020/05/24.
//  Copyright © 2020 nekowen. All rights reserved.
//

import AppKit

extension NSWorkspace {
    func runningApplication(bundleIdentifier: String) -> NSRunningApplication? {
        let processes = self.runningApplications
        return processes.first { $0.bundleIdentifier == bundleIdentifier }
    }
}
