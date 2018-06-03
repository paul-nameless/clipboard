//
//  PreferencesViewController.swift
//  ClipHistory
//
//  Created by paul on 6/1/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.parent?.view.window?.title = self.title!
    }
    
}
