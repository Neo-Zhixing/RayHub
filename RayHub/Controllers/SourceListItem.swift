//
//  SourceListItem.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/6/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

class SourceListItem: NSObject {
    let title: String
    let image: NSImage?
    let segue: NSStoryboardSegue.Identifier?
    let isHeader: Bool
    
    var children: [SourceListItem]
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

class ManagedSourceListItem<Item>: SourceListItem, NSFetchedResultsControllerDelegate where Item: NSFetchRequestResult {
    var controller: NSFetchedResultsController<Item>
    var childrenItemProvier: (Item) -> SourceListItem
    
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
        self.children = self.controller.fetchedObjects!.map(self.childrenItemProvier)
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print(anObject)
    }
}
