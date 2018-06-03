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
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        
        self.window?.orderOut(self)
//        self.view.window?.level = .floating
        return false
    }

}
