//
//  Nodes.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/9/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import SwiftUI


struct RouterNode: View {
    static let InboundSocket = InputSocket(name: "Sources", identifier: "router-inbound", multiple: true)
    static let OutboundSocket = OutputSocket(name: "Destination", identifier: "router-outbound", multiple: false)
    static let BalancerSocket = OutputSocket(name: "Balancer", identifier: "balancer-outbound", multiple: false).connect(input: BalancerNode.RouterSocket)
    
    
    @State var domains: String = ""
    @State var ips: String = ""
    @State var ports: String = ""
    @State var network = 0
    @State var `protocol` = 0
    @State var sourceIps: String = ""
    var body: some View {
        let formWidth: CGFloat = 80
        return Node(
            inputs: [RouterNode.InboundSocket],
            outputs: [RouterNode.OutboundSocket, RouterNode.BalancerSocket]
            ) {
                HStack {
                    Text("Domain:")
                        .frame(width: formWidth, alignment: .trailing)
                    MultilineTextField(text: self.$domains)
                }
                HStack {
                    Text("IPs:")
                        .frame(width: formWidth, alignment: .trailing)
                    MultilineTextField(text: self.$ips)
                }
                HStack {
                    Text("Ports:")
                        .frame(width: formWidth, alignment: .trailing)
                    TextField("Ports", text: self.$ports)
                }
                HStack {
                    Text("Source IPs:")
                        .frame(width: formWidth, alignment: .trailing)
                    TextField("Ports", text: self.$sourceIps)
                }
                Picker("Network:", selection: self.$network) {
                    Text("None")
                    Text("TCP")
                    Text("UDP")
                    Text("TCP & UDP")
                }

                Picker("Protocol:", selection: self.$protocol) {
                    Text("None")
                    Text("HTTP")
                    Text("TLS")
                    Text("BitTorrent")
                }
        }
    .frame(minWidth: 300)
    }
}

struct RouterNode_Preview: PreviewProvider {
    static var previews: some View {
        RouterNode()
        .frame(width: 300)
    }
}

