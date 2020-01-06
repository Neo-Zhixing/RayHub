//
//  SourceListItem.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/6/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

class SourceListItem: NSObject {
    @objc var title: String
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
    }
}

protocol ManagedSourceListItemDelegate: NSObjectProtocol {
    func listItem(_ parentItem: SourceListItem, didAddChild item: SourceListItem, atIndexPath indexPath: IndexPath)
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
            item.bind(NSBindingName(rawValue: "title"), to: obj, withKeyPath: "name", options: nil)
            return item
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let obj = anObject as! Item
        switch type {
        case .insert:
            let item = self.childrenItemProvier(obj)
            item.bind(NSBindingName(rawValue: "title"), to: obj, withKeyPath: "name", options: nil)
            self.delegate?.listItem(self, didAddChild: item, atIndexPath: newIndexPath!)
        default:
            ()
        }
    }
}
