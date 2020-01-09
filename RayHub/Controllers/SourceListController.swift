//
//  SourceListController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/5/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

extension NSPasteboard.PasteboardType {
    static let sourceListItem: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: "xin.neoto.SourceListItem")
}
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
        SourceListItem(
            title: "Routing",
            imageNamed: "RouteTemplate",
            segue: "RoutingSegue"
        ),
        SourceListItem(header: "Servers", [
            self.vmessServersItem,
            self.shadowsocksServersItem
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
    
    lazy var shadowsocksServersItem: ManagedSourceListItem<ShadowsocksServer> = {
        let fetchRequest: NSFetchRequest<ShadowsocksServer> = ShadowsocksServer.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "address", ascending: false)
        ]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSApplication.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: "ShadowsocksServers")
        
        let item = ManagedSourceListItem<ShadowsocksServer>(
        title: "Shadowsocks", imageNamed: "ShadowsocksTemplate", controller: fetchedResultsController) {
            server in
            SourceListItem(title: server.name ?? "Unnamed Server", imageNamed: nil, segue: "ShadowsocksServerSegue", header: false)
        }
        fetchedResultsController.delegate = item
        item.delegate = self
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.outlineView.registerForDraggedTypes([.sourceListItem])
        do {
            try self.vmessServersItem.prepare()
            try self.shadowsocksServersItem.prepare()
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
        if outlineView.selectedRow < 0 {
            return
        }
        let rowView = outlineView.rowView(atRow: outlineView.selectedRow, makeIfNecessary: false)
        let cell = rowView?.view(atColumn: outlineView.selectedColumn) as! NSTableCellView
        let item = cell.objectValue as! SourceListItem
        self.selectedItem = item
        
        self.contentViewController.select(item: item)
    }
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }
    
    // MARK: - Drag and drop to reorder
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        let aItem = item as! SourceListItem
        if aItem.associatedObject == nil {
            return nil
        }
        let pbItem:NSPasteboardItem = NSPasteboardItem()
        pbItem.setDataProvider(aItem, forTypes: [.sourceListItem])
        return pbItem
    }
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        if index == NSOutlineViewDropOnItemIndex {
            return []
        }
        guard let aItem = item as? SourceListItem else {
            return []
        }
        if let hash = info.draggingPasteboard.string(forType: .sourceListItem) {
            return Int(hash) == aItem.hash ? .move : []
        }
        return []
    }
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        return true
    }
    
    
    
    
    @IBAction func showAddMenu(sender: NSButton) {
        self.addMenu.popUp(positioning: nil, at: NSPoint(), in: sender)
    }
    @IBAction func addServer(sender: NSMenuItem) {
        let context = NSApplication.shared.persistentContainer.viewContext
        guard let id = sender.identifier else {
            return
        }
        if id.rawValue == "vmess" {
            _ = VmessServer(context: context)
        } else if id.rawValue == "shadowsocks" {
            _ = ShadowsocksServer(context: context)
        }
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
        self.outlineView.insertItems(at: indexSet, inParent: parentItem, withAnimation: .slideLeft)
    }
    func listItem(_ parentItem: SourceListItem, didRemoveChild item: SourceListItem, atIndexPath indexPath: IndexPath) {
        let indexSet =  IndexSet(integer: indexPath.item)
        self.outlineView.removeItems(at: indexSet, inParent: parentItem, withAnimation: .slideRight)
    }
    func listItem(_ parentItem: SourceListItem, didUpdateChild item: SourceListItem, atIndexPath indexPath: IndexPath, to object: Any) {
        if let server = object as? VmessServer {
            item.title = server.name ?? "Untitled"
            let row = self.outlineView.row(forItem: item)
            let rowView = self.outlineView.rowView(atRow: row, makeIfNecessary: false)
            let colView = rowView?.view(atColumn: 0) as? NSTableCellView
            colView?.textField?.stringValue = item.title
        }
    }
    func listItemStartUpdate(item: SourceListItem) {
        self.outlineView.beginUpdates()
    }
    func listItemEndUpdate(item: SourceListItem) {
        self.outlineView.endUpdates()
    }
}
