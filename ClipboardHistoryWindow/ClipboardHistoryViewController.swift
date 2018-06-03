//
//  ClipboardHistoryViewController.swift
//  ClipHistory
//
//  Created by paul on 6/2/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa

class ClipboardHistoryViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        self.view.layer?.cornerRadius = 24
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.parent?.view.window?.title = self.title!
    }
}
