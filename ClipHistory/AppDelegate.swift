//
//  AppDelegate.swift
//  ClipHistory
//
//  Created by paul on 5/31/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa
import Foundation
import Magnet

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let KEY_V: UInt16 = 0x09
    var timer = Timer()
    var clipboardChangeCount: Int = 0
    var preferencesController: NSWindowController?
    var clipboardHistoryController: NSWindowController?
    var stack: ClipboardStack = ClipboardStack()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        buildMenu()
        setupShortcut()
       
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkClipboard(_:)), userInfo: nil, repeats: true)

//        // get a global concurrent queue
//        let background = DispatchQueue.global()
//        // submit a task to the queue for background execution
//        background.async {
//            if let clip = self.clipboardContent() {
//                print("Clipboard = \(clip)")
//            }
//        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    @objc func hotKeyHandler() {
        print("Clipboards:")
        for (clipboard, timestamp) in stack.items {
            print("\(clipboard) = \(timestamp)")
        }
    }
    
    func setupShortcut() {
        // ⌘ + Shift + V
        guard let keyCombo = KeyCombo(keyCode: 9, cocoaModifiers: [.shift, .command]) else { return }
        let hotKey = HotKey(identifier: "CommandShiftV",
                            keyCombo: keyCombo,
                            target: self,
                            action: #selector(AppDelegate.hotKeyHandler))
        hotKey.register()
    }


    func clipboardContent() -> String? {
        return NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
    }
//
//    @objc func printQuote(_ sender: Any?) {
//        print("Checking")
////        if let clip = clipboardContent() {
////            print("Clipboard = \(clip)")
////        }
//    }
    
    @objc func checkClipboard(_ sender: Any?) {
        if self.clipboardChangeCount != NSPasteboard.general.changeCount {
            self.clipboardChangeCount = NSPasteboard.general.changeCount
            print("Clipboard value change. Updating values")
            if let clipboard = clipboardContent() {
                stack.push(clipboard)
                buildMenu()
            }
        }
    }
    
    // utils
    func trunc(string: String, length: Int, trailing: String = "") -> String {
        return (string.count > length) ? string.prefix(length) + trailing : string
    }

    // init
    func buildMenu() {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            //            button.action = #selector(printQuote(_:))
        }

        let menu = NSMenu()
        
        let clipboards = stack.items.sorted { a, b in a.value > b.value }.enumerated().filter { i, e in i < 10 }
        for (i, elem) in clipboards {
            menu.addItem(NSMenuItem(title: trunc(string: elem.key, length: 44, trailing: "..."),
                                    action: #selector(AppDelegate.paste(_:)),
                                    keyEquivalent: "\(i + 1)"))
        }
        menu.addItem(NSMenuItem(title: "ClipboardHistory",
                                action: #selector(AppDelegate.showClipboardHistory(_:)),
                                keyEquivalent: "H"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Clear", action: #selector(AppDelegate.clear(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preferences...",
                                action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "About", action: #selector(AppDelegate.showAbout(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "Q"))
        
        statusItem.menu = menu
    }
    
    // button
    @objc func clear(_ sender: Any?) {
    }
    
    // button
    @objc func showAbout(_ sender: Any?) {
    }
    
    // button
    @objc func showPreferences(_ sender: Any?) {
        if !(preferencesController != nil) {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if preferencesController != nil {
            preferencesController!.showWindow(sender)
        }
    }
    
    // button
    @objc func showClipboardHistory(_ sender: Any?) {
        if !(clipboardHistoryController != nil) {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "ClipboardHistory"), bundle: nil)
            clipboardHistoryController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if clipboardHistoryController != nil {
            clipboardHistoryController!.showWindow(sender)
        }
    }
    
    @objc func pasteElem(_ sender: Any?, clipboard: String) {
        NSPasteboard.general.setString(clipboard, forType: NSPasteboard.PasteboardType(clipboard))
        self.send(self.KEY_V, useCommandFlag: true)
    }

    @objc func paste(_ sender: Any?) {
        self.send(self.KEY_V, useCommandFlag: true)

    }

    func send(_ keyCode: CGKeyCode, useCommandFlag: Bool) {
        let sourceRef = CGEventSource(stateID: .combinedSessionState)
        
        if sourceRef == nil {
            NSLog("FakeKey: No event source")
            return
        }
        
        let keyDownEvent = CGEvent(keyboardEventSource: sourceRef,
                                   virtualKey: keyCode,
                                   keyDown: true)
        if useCommandFlag {
            keyDownEvent?.flags = .maskCommand
        }
        
        let keyUpEvent = CGEvent(keyboardEventSource: sourceRef,
                                 virtualKey: keyCode,
                                 keyDown: false)
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }

}




struct ClipboardStack {
    
    var items: [String: Double] = [:]
    let maxCapacity = 4
    
    mutating func trim() {
        if (items.count > maxCapacity) {
            for _ in 1...items.count - maxCapacity {
                let element = items.max { a, b in a.value > b.value }?.key
                if let item = element {
                    items.removeValue(forKey: item)
                }
            }
        }
    }
    
    mutating func push(_ item: String) {
        items[item] = Date().timeIntervalSince1970
        trim()
    }
    
    mutating func last() -> String? {
        return items.max { a, b in a.value > b.value }?.key
    }
}



// Utils
//extension Date {
//
//    func getElapsedInterval() -> String {
//
//        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
//
//        if let year = interval.year, year > 0 {
//            return year == 1 ? "\(year)" + " " + "year" :
//                "\(year)" + " " + "years"
//        } else if let month = interval.month, month > 0 {
//            return month == 1 ? "\(month)" + " " + "month" :
//                "\(month)" + " " + "months"
//        } else if let day = interval.day, day > 0 {
//            return day == 1 ? "\(day)" + " " + "day" :
//                "\(day)" + " " + "days"
//        } else {
//            return "a moment ago"
//
//        }
//
//    }
//}
