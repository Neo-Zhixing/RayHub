//
//  ContentViewController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/5/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

class ContentViewController: NSViewController {
    private var currentViewController: NSViewController?
    
    private var sourceListViewController: SourceListController {
        get {
            return self.parent!.children[0] as! SourceListController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        select(item: self.sourceListViewController.selectedItem)
    }
    
    func switchTo(viewController: NSViewController) {
        self.currentViewController?.view.removeFromSuperview()
        self.currentViewController?.removeFromParent()
        self.currentViewController = viewController
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
    }
    func select(item: SourceListItem) {
        if let segue = item.segue {
            self.performSegue(withIdentifier: segue, sender: item)
        }
    }
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // let item = sender! as! SourceListItem
        // let aSegue = segue as! ContentViewReplaceSegue
    }
}

class ContentViewReplaceSegue: NSStoryboardSegue {
    override func perform() {
        let sourceVC = self.sourceController as! ContentViewController
        let destinationVC = self.destinationController as! NSViewController
        sourceVC.switchTo(viewController: destinationVC)
    }
}

