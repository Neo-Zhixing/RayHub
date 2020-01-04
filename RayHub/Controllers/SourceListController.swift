//
//  SourceListController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/5/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

struct SourceListItem {
    let title: String
    let image: NSImage?
    let segue: NSStoryboardSegue.Identifier
    init(title: String, imageNamed: String, segue: String) {
        self.title = title
        self.segue = segue
        self.image = NSImage(named: imageNamed)
    }
}


class SourceListController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    private var contentViewController: ContentViewController {
        get {
            return self.parent!.children[1] as! ContentViewController
        }
    }
    
    var selectedItem: SourceListItem = SourceListController.items[0]
    
    static let items = [
        SourceListItem(
            title: "Connection",
            imageNamed: "GlobeTemplate",
            segue: "ConnectionSegue"
        ),
        SourceListItem(
            title: "Servers",
            imageNamed: "ServerTemplate",
            segue: "ServerSegue"
        )
    ]
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return SourceListController.items.count
        }
        return 0
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return SourceListController.items[index]
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let aItem = item as! SourceListItem
        let cellIdentifier = NSUserInterfaceItemIdentifier("DataCell")
        let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        cell.textField!.stringValue = aItem.title
        cell.imageView!.image = aItem.image
        cell.objectValue = aItem
        return cell
    }
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let outlineView = notification.object as! NSOutlineView
        let rowView = outlineView.rowView(atRow: outlineView.selectedRow, makeIfNecessary: false)
        let cell = rowView?.view(atColumn: outlineView.selectedColumn) as! NSTableCellView
        let item = cell.objectValue as! SourceListItem
        
        self.contentViewController.select(item: item)
    }
    
}
