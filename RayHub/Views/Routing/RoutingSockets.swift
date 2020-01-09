//
//  RoutingSockets.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/9/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import Foundation

let InboundReceiverSocket = InputSocket(name: "InboundReceiver", identifier: "inbound-receiver")

let InboundSocket = OutputSocket(name: "Inbounds", identifier: "inbounds")
    .connect(input: InboundReceiverSocket)

