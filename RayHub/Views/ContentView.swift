//
//  ContentView.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/4/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        Text("Hello World")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: DetailView()) {
                    Text("One")
                }
                NavigationLink(destination: DetailView()) {
                    Text("Two")
                }
            }.listStyle(SidebarListStyle())
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ContentViewHostingController: NSHostingController<ContentView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ContentView())
    }
}
