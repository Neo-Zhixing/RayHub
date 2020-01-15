//
//  RouteViewController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/10/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit



class RouteViewController: NSViewController {
    @IBOutlet weak var networkSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var protocolSegmentedControl: NSSegmentedControl!
    
    override func viewDidLoad() {
        let route = self.representedObject as! Route
        for num in 0 ..< 2 {
            let tag: Int16 = 0b1 << num
            let selected = route.network & tag != 0
            self.networkSegmentedControl.setSelected(selected, forSegment: num)
        }
        for num in 0 ..< 3 {
            let tag: Int16 = 0b1 << num
            let selected = route.protocols & tag != 0
            self.protocolSegmentedControl.setSelected(selected, forSegment: num)
        }
    }
    
    @IBAction func networkSegmentedControlUpdated(sender: NSSegmentedControl) {
        let route = self.representedObject as! Route
        var network: Int16 = 0
        for num in 0 ..< 2 {
            if sender.isSelected(forSegment: num) {
                let tag: Int16 = 0b1 << num
                network |= tag
            }
        }
        route.network = network
    }
    
    @IBAction func protocolSegmentedControlUpdated(sender: NSSegmentedControl) {
        let route = self.representedObject as! Route
        var protocols: Int16 = 0
        for num in 0 ..< 3 {
            if sender.isSelected(forSegment: num) {
                let tag: Int16 = 0b1 << num
                protocols |= tag
            }
        }
        route.protocols = protocols
    }
}
