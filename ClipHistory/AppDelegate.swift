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
       
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkClipboard(_:)), userInfo: nil, repeats: true)

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

    func iHaveFocus() -> Bool {
        let win = NSApplication.shared.keyWindow
        if (win != nil) {
            let vc = win!.contentViewController as? ClipboardHistoryViewController
            if (vc != nil) {
                return true
            }
        }
        return false
    }
    
    @objc func hotKeyHandler() {
        if iHaveFocus() {
            NSApp.hide(nil)
        } else {
            showClipboardHistory()
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

    @objc func checkClipboard(_ sender: Any?) {
        if self.clipboardChangeCount != NSPasteboard.general.changeCount {
            self.clipboardChangeCount = NSPasteboard.general.changeCount
            print("Clipboard value changed, updating values")
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
            let key = indexToButton(i)
        
            let menuItem = NSMenuItem(title: trunc(string: elem.key, length: 44, trailing: "..."),
                                      action: #selector(AppDelegate.pasteElem(_:)),
                                      keyEquivalent: key)
            menuItem.tag = i
            menu.addItem(menuItem)
        }
        menu.addItem(NSMenuItem(title: "ClipboardHistory",
                                action: #selector(AppDelegate.showClipboardHistoryHandler(_:)),
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
        if preferencesController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }

        if preferencesController != nil {
            preferencesController!.showWindow(nil)
//            print("Show pref")
        }
    }
    
    // button
    @objc func showClipboardHistoryHandler(_ sender: Any?) {
        showClipboardHistory()
    }

    func showClipboardHistory() {
        if clipboardHistoryController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "ClipboardHistory"), bundle: nil)
            clipboardHistoryController = storyboard.instantiateInitialController() as? ClipboardHistoryWindowController
//            clipboardHistoryController.stack = self.stack
        }
        
        if clipboardHistoryController    != nil {
//            print("Show hist")
            clipboardHistoryController!.showWindow(nil)
            clipboardHistoryController?.window?.orderFront(clipboardHistoryController)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func pasteElem(_ sender: Any?) {
        let menuItem = sender as! NSMenuItem
        let index = menuItem.tag
        pasteByIndex(index)
    }
    
    func pasteByIndex(_ index: Int) {
        if let content = stack.get(index: index) {
            print("Content \(content)")
            let pb = NSPasteboard.init(name: NSPasteboard.Name.general)
            pb.clearContents()
            pb.string(forType: NSPasteboard.PasteboardType.string)
            pb.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
            let success = pb.setString(content, forType: NSPasteboard.PasteboardType.string)
            print("Success \(success)")
            self.send(self.KEY_V, useCommandFlag: true)
        }
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
    let maxCapacity = 100
    let KEY = "clipboardStack"
    
    init() {
        let stackObject = UserDefaults.standard.object(forKey: self.KEY)
        if let stack = stackObject as? [String: Double] {
            self.items = stack
        } else {
            self.items = [:]
        }
    }
    
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
        UserDefaults.standard.set(self.items, forKey: self.KEY)
    }
    
    mutating func last() -> String? {
        return items.max { a, b in a.value > b.value }?.key
    }
    
    mutating func get(index: Int) -> String? {
        let sortedItems = items.sorted { a, b in a.value > b.value }
        if index < sortedItems.count {
            return sortedItems[index].key
        }
        return nil
    }
    
    mutating func getSorted() -> [(key: String, value: Double)] {
        return items.sorted { a, b in a.value > b.value }
    }
}


// utils
func indexToButton(_ i: Int) -> String {
    return i < 9 ? "\(i + 1)": i == 9 ? "0" : ""
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
