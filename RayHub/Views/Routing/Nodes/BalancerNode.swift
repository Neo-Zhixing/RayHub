//
//  BalancerNode.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/10/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import SwiftUI


struct BalancerNode: View {
    static let RouterSocket = InputSocket(name: "Router", identifier: "balancer-input")
    static let OutboundSocket = OutputSocket(name: "Destination", identifier: "router-outbound", multiple: true)
    var body: some View {
        return Node(
            inputs: [BalancerNode.RouterSocket],
            outputs: [RouterNode.OutboundSocket, RouterNode.BalancerSocket]
        ) {
            EmptyView()
        }
    }
}


