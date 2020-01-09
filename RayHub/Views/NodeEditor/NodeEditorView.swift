//
//  RoutingView.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/7/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import SwiftUI

struct NodeEditorView: View {
    @State var a = "default"
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            Node(
                inputs: [InboundReceiverSocket],
                outputs: [InboundSocket]
                ) {
                TextField("Good", text: self.$a)
            }
        }
        .background(Color(NSColor.underPageBackgroundColor))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
