//
//  SourceListController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/5/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

class SourceListController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, ManagedSourceListItemDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet var addMenu: NSMenu!
    @IBOutlet var removeButton: NSButton!
    
    private var contentViewController: ContentViewController {
        get {
            return self.parent!.children[1] as! ContentViewController
        }
    }
    
    var selectedItem: SourceListItem! {
        didSet {
            self.removeButton.isEnabled = self.selectedItem.associatedObject != nil
        }
    }
    
    lazy var items: [SourceListItem] = [
        SourceListItem(
            title: "Status",
            imageNamed: "GlobeTemplate",
            segue: "ConnectionSegue"
        ),
        SourceListItem(header: "Servers", [
            self.vmessServersItem,
            SourceListItem(
                title: "Shadowsocks",
                imageNamed: "ShadowsocksTemplate",
                segue: "VmessServerSegue"
            )
        ]),
    ]
    
    
    lazy var vmessServersItem: ManagedSourceListItem<VmessServer> = {
        let fetchRequest: NSFetchRequest<VmessServer> = VmessServer.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "address", ascending: false)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSApplication.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "VmessServers")
        
        let item = ManagedSourceListItem<VmessServer>(
        title: "Vmess", imageNamed: "ServerTemplate", controller: fetchedResultsController) {
            server in
            SourceListItem(title: server.name ?? "Unnamed Server", imageNamed: nil, segue: "VmessServerSegue", header: false)
        }
        fetchedResultsController.delegate = item
        item.delegate = self
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try self.vmessServersItem.prepare()
        } catch let err {
            NSAlert(error: err).runModal()
        }
        
        
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
        let cellIdentifier: NSUserInterfaceItemIdentifier
        if aItem.isHeader {
            cellIdentifier = NSUserInterfaceItemIdentifier("HeaderCell")
        } else if aItem.image == nil {
            cellIdentifier = NSUserInterfaceItemIdentifier("TextCell")
        } else {
            cellIdentifier = NSUserInterfaceItemIdentifier("TextImageCell")
        }
        let cell: NSTableCellView = outlineView.makeView(withIdentifier: cellIdentifier, owner: self) as! NSTableCellView
        cell.textField?.bind(NSBindingName.value, to: aItem, withKeyPath: "title", options: nil)
        //cell.textField?.stringValue = aItem.title
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
        self.selectedItem = item
        
        self.contentViewController.select(item: item)
    }
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }
    
    
    
    @IBAction func showAddMenu(sender: NSButton) {
        self.addMenu.popUp(positioning: nil, at: NSPoint(), in: sender)
    }
    @IBAction func addServer(sender: NSMenuItem) {
        let context = NSApplication.shared.persistentContainer.viewContext
        _ = VmessServer(context: context)
    }
    @IBAction func removeItem(sender: NSButton)  {
        let row = outlineView.selectedRow
        let rowView = outlineView.rowView(atRow: row, makeIfNecessary: false)
        let cell = rowView?.view(atColumn: outlineView.selectedColumn) as! NSTableCellView
        let item = cell.objectValue as! SourceListItem
        
        if let obj = item.associatedObject as? NSManagedObject {
            NSApplication.shared.persistentContainer.viewContext.delete(obj)
        }

    }
    
    func listItem(_ parentItem: SourceListItem, didAddChild item: SourceListItem, atIndexPath indexPath: IndexPath) {
        let indexSet = IndexSet(integer: indexPath.item)
        print(indexSet, indexPath.item, self.items)
        self.outlineView.insertItems(at: indexSet, inParent: parentItem, withAnimation: .slideLeft)
    }
    func listItem(_ parentItem: SourceListItem, didRemoveChild item: SourceListItem, atIndexPath indexPath: IndexPath) {
        let indexSet =  IndexSet(integer: indexPath.item)
        print(indexPath.item)
        self.outlineView.removeItems(at: indexSet, inParent: parentItem, withAnimation: .slideRight)
    }
    func listItemStartUpdate(item: SourceListItem) {
        self.outlineView.beginUpdates()
    }
    func listItemEndUpdate(item: SourceListItem) {
        self.outlineView.endUpdates()
    }
}
