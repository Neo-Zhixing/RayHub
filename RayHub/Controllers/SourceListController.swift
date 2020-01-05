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
    let segue: NSStoryboardSegue.Identifier?
    let isHeader: Bool
    let children: [SourceListItem]
    init(title: String, imageNamed: String, segue: String) {
        self.title = title
        self.segue = segue
        self.image = NSImage(named: imageNamed)
        self.isHeader = false
        self.children = []
    }
    init(header: String, _ children: [SourceListItem]) {
        self.title = header
        self.isHeader = true
        self.children = children
        self.image = nil
        self.segue = nil
    }
}


class SourceListController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    private var contentViewController: ContentViewController {
        get {
            return self.parent!.children[1] as! ContentViewController
        }
    }
    
    var selectedItem: SourceListItem!
    
    var items: [SourceListItem] = [
        SourceListItem(
            title: "Status",
            imageNamed: "GlobeTemplate",
            segue: "ConnectionSegue"
        ),
        SourceListItem(header: "Servers", [
            SourceListItem(
                title: "Servers",
                imageNamed: "ServerTemplate",
                segue: "ServerSegue"
            )
        ]),
    ]
    
    
    lazy var vmessServersController: NSFetchedResultsController<VmessServer> = {
        let fetchRequest: NSFetchRequest<VmessServer> = VmessServer.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "address", ascending: false)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSApplication.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "VmessServers")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try! self.vmessServersController.performFetch()
        
        for item in self.items {
            if !item.isHeader {
                self.selectedItem = item
                break
            }
        }
        
        self.outlineView.expandItem(nil, expandChildren: true)
    }
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let aItem = item as? SourceListItem {
            return aItem.children.count
        } else {
            return self.items.count
        }
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let aItem = item as! SourceListItem
        return !aItem.children.isEmpty
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let aItem = item as? SourceListItem {
            return aItem.children[index]
        } else {
            return self.items[index]
        }
    }
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let aItem = item as? SourceListItem {
            return aItem.segue != nil
        }
        return false
    }
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let aItem = item as! SourceListItem
        let cell: NSTableCellView
        if aItem.isHeader {
            let cellIdentifier = NSUserInterfaceItemIdentifier("HeaderCell")
            cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        } else {
            let cellIdentifier = NSUserInterfaceItemIdentifier("DataCell")
            cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        }
        cell.textField?.stringValue = aItem.title
        cell.imageView?.image = aItem.image
        cell.objectValue = aItem
        return cell
    }
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        let aItem = item as! SourceListItem
        return aItem.isHeader
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let outlineView = notification.object as! NSOutlineView
        let rowView = outlineView.rowView(atRow: outlineView.selectedRow, makeIfNecessary: false)
        let cell = rowView?.view(atColumn: outlineView.selectedColumn) as! NSTableCellView
        let item = cell.objectValue as! SourceListItem
        
        self.contentViewController.select(item: item)
    }
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }
}
