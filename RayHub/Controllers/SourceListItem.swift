//
//  SourceListItem.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/6/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

class SourceListItem: NSObject {
    weak var parent: SourceListItem?
    var title: String
    let image: NSImage?
    let segue: NSStoryboardSegue.Identifier?
    let isHeader: Bool
    
    var children: [SourceListItem]
    @objc var associatedObject: AnyObject? = nil
    init(title: String, imageNamed: String?, segue: String? = nil, header: Bool = false) {
        self.title = title
        self.segue = segue
        if let i = imageNamed {
            self.image = NSImage(named: i)
        } else {
            self.image = nil
        }
        self.isHeader = header
        self.children = []
    }
    init(header: String, _ children: [SourceListItem]) {
        self.title = header
        self.isHeader = true
        self.children = children
        self.image = nil
        self.segue = nil
        super.init()
        for c in children {
            c.parent = self
        }
    }
    
    override var description: String {
        get {
            if self.children.isEmpty {
                return self.title
            }
            return "\(self.title) [\(self.children.map({item in item.description}).joined(separator: ", "))]"
        }
    }
}

protocol ManagedSourceListItemDelegate: NSObjectProtocol {
    func listItem(_ parentItem: SourceListItem, didAddChild item: SourceListItem, atIndexPath indexPath: IndexPath)
    func listItem(_ parentItem: SourceListItem, didRemoveChild item: SourceListItem, atIndexPath indexPath: IndexPath)
    func listItem(_ parentItem: SourceListItem, didUpdateChild item: SourceListItem, atIndexPath indexPath: IndexPath, to object: Any)
    func listItemStartUpdate(item: SourceListItem)
    func listItemEndUpdate(item: SourceListItem)
}
class ManagedSourceListItem<Item>: SourceListItem, NSFetchedResultsControllerDelegate where Item: NSFetchRequestResult {
    var controller: NSFetchedResultsController<Item>
    var childrenItemProvier: (Item) -> SourceListItem
    weak var delegate: ManagedSourceListItemDelegate?
    
    init(
        title: String,
        imageNamed: String,
        segue: String? = nil,
        header: Bool = false,
        controller: NSFetchedResultsController<Item>,
        childrenItemProvier provider: @escaping (Item) -> SourceListItem
    ) {
        self.controller = controller
        self.childrenItemProvier = provider
        super.init(
            title: title,
            imageNamed: imageNamed,
            segue: segue,
            header: header
        )
    }
    
    func prepare() throws {
        try self.controller.performFetch()
        self.children = self.controller.fetchedObjects!.map {
            obj in
            let item = self.childrenItemProvier(obj)
            item.associatedObject = obj
            item.parent = self
            return item
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let obj = anObject as! Item
        switch type {
        case .insert:
            let item = self.childrenItemProvier(obj)
            self.children.insert(item, at: newIndexPath!.item)
            item.associatedObject = obj
            item.parent = self
            self.delegate?.listItem(self, didAddChild: item, atIndexPath: newIndexPath!)
        case .delete:
            let item = self.children.remove(at: indexPath!.item)
            self.delegate?.listItem(self, didRemoveChild: item, atIndexPath: indexPath!)
        case .update:
            let item = self.children[indexPath!.item]
            self.delegate?.listItem(self, didUpdateChild: item, atIndexPath: indexPath!, to: anObject)
        default:
            ()
        }
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.listItemEndUpdate(item: self)
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.delegate?.listItemEndUpdate(item: self)
    }
}

extension SourceListItem: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {
        if let parent = self.parent {
            item.setString(String(parent.hashValue), forType: type)
        }
    }
}
