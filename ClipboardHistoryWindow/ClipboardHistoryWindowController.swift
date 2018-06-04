//
//  ClipboardHistoryWindowController.swift
//  ClipHistory
//
//  Created by paul on 6/2/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa

class ClipboardHistoryWindowController: NSWindowController, NSWindowDelegate {

//    var stack: ClipboardStack? = nil

    override func windowDidLoad() {
        super.windowDidLoad()
//        window?.isOpaque = false
        window?.backgroundColor = .clear
//        self.window?.orderFront(self)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
//        self.window?.orderOut(self)
        return true
    }
    
    func windowDidResignKey(_ notification: Notification) {
        self.window?.close()
    }

}
