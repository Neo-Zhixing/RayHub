//
//  RoutingController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/7/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit
import SwiftUI

class RoutingViewController: NSHostingController<RoutingView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(rootView: RoutingView())
    }
}
