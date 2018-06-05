//
//  ClipboardHistoryViewController.swift
//  ClipHistory
//
//  Created by paul on 6/2/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa

class ClipboardHistoryViewController: NSViewController {
    
//    var items: [(key: String, value: Double)?] = []
//    var stack: ClipboardStack?
    var appDelegate: AppDelegate? = nil
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {

        super.viewDidLoad()
        self.parent?.view.window?.title = self.title!

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        self.view.layer?.cornerRadius = 24
        
        appDelegate = NSApplication.shared.delegate as? AppDelegate
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
//        stack = appDelegate.stack


        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 10

    }

    override func viewDidAppear() {
        super.viewDidAppear()
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
//        items = appDelegate.stack.getSorted()
        self.tableView.reloadData()
        let indexSet = IndexSet.init(integer: 0)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
        print("Here, updating")
        self.parent?.view.window?.title = self.title!
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 0x24 {
            // enter
            print("Handled enter press")
//            self.parent?.view.window?.close()
            NSApp.hide(nil)
            let index = tableView.selectedRow
            if index == -1 {
                return
            }
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.pasteByIndex(index)
        } else if event.keyCode == 0x35 {
            // escape
//            self.parent?.view.window?.close()
            NSApp.hide(nil)
        }
    }
}


extension ClipboardHistoryViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        return appDelegate?.stack.items.count ?? 0
    }
    
}


class MyNSTableRowView: NSTableRowView {
    
    override func drawSelection(in dirtyRect: NSRect) {
        self.wantsLayer = true
        self.layer?.cornerRadius = 16
        if self.selectionHighlightStyle != .none {
            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
            NSColor(calibratedWhite: 0.82, alpha: 1).setFill()
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 10, yRadius: 10)
            selectionPath.fill()
        }
    }
}


extension ClipboardHistoryViewController: NSTableViewDelegate {
    
    fileprivate enum CellId {
        static let clipboardCell = "clipboard"
        static let timestampCell = "timestamp"
        static let shortcutCell = "shortcut"
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MyNSTableRowView()
    }
//
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        let index = tableView.selectedRow
//        let rowView = tableView.rowView(atRow: index, makeIfNecessary: false)
//        rowView?.isEmphasized = false
//    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellIdentifier: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        
        // 1
//        let appDelegate = NSApplication.shared.delegate as! AppDelegate
//        if row >= appDelegate?.stack.items?.count {
//            return nil
//        }
        guard let item = appDelegate?.stack.getSorted()[row] else {
            return nil
        }

//        guard let item = stack?.getSorted()[row] else {
//            return nil
//        }
//
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = item.key
            cellIdentifier = CellId.clipboardCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = toTimeAgo(Date(timeIntervalSince1970: item.value))
            cellIdentifier = CellId.timestampCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = row < 9 ? "⌘\(row + 1)": row == 9 ? "⌘0" : ""
            cellIdentifier = CellId.shortcutCell
        }
        
        // 3
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),
                                         owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}



extension NSTextFieldCell {
//    override open func drawingRect(forBounds rect: NSRect) -> NSRect {
//        return NSRect(x: rect.minX + 10, y: rect.minY + 10, width: rect.width, height: 44)
//    }
}

// utils

func toTimeAgo(_ date: Date) -> String {
    let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: Date())
    if let year = interval.year, year > 0 {
        return year == 1 ? "\(year)" + " " + "year" :
            "\(year)" + " " + "years"
    } else if let month = interval.month, month > 0 {
        return month == 1 ? "\(month)" + " " + "month" :
            "\(month)" + " " + "months"
    } else if let day = interval.day, day > 0 {
        return day == 1 ? "\(day)" + " " + "day" :
            "\(day)" + " " + "days"
    } else if let hour = interval.hour, hour > 0 {
        return hour == 1 ? "\(hour)" + " " + "hour" :
            "\(hour)" + " " + "hours"
    } else if let minute = interval.minute, minute > 0 {
        return minute == 1 ? "\(minute)" + " " + "minute" :
            "\(minute)" + " " + "minutes"
    } else {
        return "a moment ago"
        
    }
}
