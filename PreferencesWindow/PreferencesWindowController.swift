//
//  PreferencesWindowController.swift
//  ClipHistory
//
//  Created by paul on 6/1/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        self.window?.orderOut(self)
        return false
    }

}
