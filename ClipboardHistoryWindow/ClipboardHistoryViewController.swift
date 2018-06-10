//
//  ClipboardHistoryViewController.swift
//  ClipHistory
//
//  Created by paul on 6/2/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class ClipboardHistoryViewController: NSViewController {

    var appDelegate: AppDelegate? = nil
    let mapKeyCodeToNumber: [UInt16: Int] = [
        0x12: 1,
        0x13: 2,
        0x14: 3,
        0x15: 4,
        0x17: 5,
        0x16: 6,
        0x1A: 7,
        0x1C: 8,
        0x19: 9,
        0x1D: 0
    ]
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {

        super.viewDidLoad()
        self.parent?.view.window?.title = self.title!

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        self.view.layer?.cornerRadius = 24
        
        appDelegate = NSApplication.shared.delegate as? AppDelegate
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 10
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.tableView.reloadData()
        let indexSet = IndexSet.init(integer: 0)
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
        self.parent?.view.window?.title = self.title!
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x33:
            // delete
            let index = tableView.selectedRow
            if index == -1 {
                return
            }
            appDelegate?.stack.remove(index)
            self.tableView.reloadData()
            tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        case 0x24:
            // enter
            NSApp.hide(nil)
            if let history = appDelegate?.stack.getSorted() {
                let flags = event.modifierFlags
                var separator = " "
                if flags.contains(NSEvent.ModifierFlags.command) {
                    separator = "\n"
                } else if flags.contains(NSEvent.ModifierFlags.option) {
                    separator = ""
                }
                let clipboard = tableView.selectedRowIndexes.filter { $0 < history.count }.map { history[$0].key }.joined(separator: separator)
                appDelegate?.pasteContent(clipboard)
                return
            }
        case 0x35:
            // escape
            NSApp.hide(nil)
        case 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x19, 0x1A, 0x1C, 0x1D:
            // 0-9
            let flags = event.modifierFlags
            if flags.contains(NSEvent.ModifierFlags.command) {
                NSApp.hide(nil)
                let index = mapKeyCodeToNumber[event.keyCode]!
                appDelegate?.pasteByIndex(index)
            }
        default:
            return
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
    
    // Used to change selection color and round corners
    override func drawSelection(in dirtyRect: NSRect) {
        self.wantsLayer = true
        self.layer?.cornerRadius = 16
        if self.selectionHighlightStyle != .none {
            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
            // gray
//            NSColor(calibratedWhite: 0.81, alpha: 1).setFill()
            // blue
            NSColor(calibratedRed: 0.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0).setFill()
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

//    func tableViewSelectionDidChange(_ notification: Notification) {
//        let index = tableView.selectedRow
//        let rowView = tableView.rowView(atRow: index, makeIfNecessary: false)
//        rowView?.isEmphasized = false
//    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
//        let c: NSTextFieldCell? = (tableColumn?.dataCell as? NSTextFieldCell)!
//        if let c2 = c {
//            print("Here")
//            c2.textColor = NSColor.black
//        }
        var text: String = ""
        var cellIdentifier: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long

        guard let item = appDelegate?.stack.getSorted()[row] else {
            return nil
        }

        if tableColumn == tableView.tableColumns[0] {
            text = truncForWindow(item.key)
            cellIdentifier = CellId.clipboardCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = toTimeAgo(Date(timeIntervalSince1970: item.value))
            cellIdentifier = CellId.timestampCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = row < 9 ? "⌘\(row + 1)": row == 9 ? "⌘0" : ""
            cellIdentifier = CellId.shortcutCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),
                                         owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
//            cell.textField?.textColor = NSColor.black
//            cell.backgroundStyle = .light
            
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

func truncForWindow(_ string: String) -> String {
    var str = string
    if str.count > 1000 {
        str = str.prefix(1000) + ""
    }
    str = str.replacingOccurrences(of: "\n", with: "⏎")
    return str
    
}

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
