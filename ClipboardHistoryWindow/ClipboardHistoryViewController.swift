//
//  ClipboardHistoryViewController.swift
//  ClipHistory
//
//  Created by paul on 6/2/18.
//  Copyright © 2018 Paul Nameless. All rights reserved.
//

import Cocoa

class ClipboardHistoryViewController: NSViewController {
    
    var items: [[String: Double]?] = [
        ["clipboard1": 1528004330.583657],
        ["clipboard2": 1528004330.583657],
        ["clipboard3": 1528004330.583657]
    ]
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.parent?.view.window?.title = self.title!

        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        self.view.layer?.cornerRadius = 24

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        scrollView.wantsLayer = true
        scrollView.layer?.cornerRadius = 10
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        self.parent?.view.window?.title = self.title!
    }
}


extension ClipboardHistoryViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count 
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
        guard let item = items[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = (item.first?.key)!
            cellIdentifier = CellId.clipboardCell
        } else if tableColumn == tableView.tableColumns[1] {
//            text = dateFormatter.string(from: Date(timeIntervalSince1970: item.first!.value))
            text = "\(item.first!.value)"
            cellIdentifier = CellId.timestampCell
        } else if tableColumn == tableView.tableColumns[2] {
            if row < 10 {
                text = "\(row)"
            } else {
                text = ""
            }
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
    override open func drawingRect(forBounds rect: NSRect) -> NSRect {
        return NSRect(x: rect.minX + 10, y: rect.minY + 10, width: rect.width, height: 44)
    }
}
