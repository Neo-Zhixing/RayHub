//
//  Node.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/8/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import SwiftUI

extension InputSocket: Identifiable {
    
}
extension OutputSocket: Identifiable {
    
}


struct Node<Content>: View where Content: View {
    let paddingSize: CGFloat = 20
    let circleSize: CGFloat = 10
    let content: () -> Content
    @State var title: String = "Node"
    var inputSockets: [InputSocket]
    var outputSockets: [OutputSocket]
    
    @State var position = CGPoint()
    @GestureState var dragState = DragState.inactive
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        var translation: CGSize {
            get {
                if case .dragging(let translation) = self {
                    return translation
                } else {
                    return .zero
                }
            }
        }
        var isDragging: Bool {
            get {
                if case .dragging = self {
                    return true
                } else {
                    return false
                }
            }
        }
        var isInactive: Bool {
            get {
                if case .inactive = self {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    init(inputs: [InputSocket], outputs: [OutputSocket], @ViewBuilder content: @escaping () -> Content) {
        self.inputSockets = inputs
        self.outputSockets = outputs
        self.content = content
    }
    
    var body: some View {
        VStack {
            TextField("Name", text: $title)
                .font(Font.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textFieldStyle(PlainTextFieldStyle())
            Divider()
            ForEach(self.inputSockets) {
                socket in
                Text(socket.name)
                    .font(Font.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        NodeSocket(direction: .left)
                            .frame(width: 10, height: 10)
                            .offset(x: -self.paddingSize, y: 0),
                        alignment: .leading)

            }
            self.content()
            ForEach(self.outputSockets) {
                socket in
                Text(socket.name)
                    .font(Font.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .overlay(
                        NodeSocket(direction: .right)
                            .frame(width: 10, height: 10)
                            .offset(x: self.paddingSize, y: 0),
                        alignment: .trailing)

            }
        }
        .padding(20)
        .frame(minWidth: 180, minHeight: 250, alignment: .top)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(self.dragState.isInactive ? Color(NSColor.controlColor) : Color(NSColor.selectedControlColor),
                lineWidth: self.dragState.isDragging ? 3 : 1))
        .position(
            x: self.position.x + self.dragState.translation.width,
            y: self.position.y + self.dragState.translation.height)
            
            .gesture(LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture())
            .updating($dragState) {
                value, state, transaction in
                switch value {
                case .first(true):
                    state = .pressing
                case .second(true, let drag):
                    state = .dragging(translation: drag?.translation ?? .zero)
                default:
                    state = .inactive
                }
            }
            .onEnded {
                value in
                guard case .second(true, let drag?) = value else { return }
                self.position.x += drag.translation.width
                self.position.y += drag.translation.height
            })
    }
    
    
    func title(_ title: String) -> some View {
        self.title = title
        return self
    }
}


fileprivate struct NodeSocket: View {
    enum Direction {
        case left
        case right
    }
    let size: CGSize = CGSize(width: 12, height: 10)
    let direction: Direction
    var body: some View {
        let pathDrawer: (inout Path) -> Void
        switch self.direction {
        case .left:
            pathDrawer = self.drawLeftPath
        case .right:
            pathDrawer = self.drawRightPath
        }
        return Path(pathDrawer)
            .fill(style: FillStyle(eoFill: false, antialiased: false))
    }
    
    func drawLeftPath(path: inout Path) {
        let h = self.size.height
        let r = h / 2
        let sLen = self.size.width - r
        
        path.addArc(center: CGPoint(x: sLen, y: r), radius: r, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: sLen, y: 0))

        path.addLine(to: CGPoint(x: sLen, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
    }
    
    func drawRightPath(path: inout Path) {
        let w = self.size.width
        let h = self.size.height
        let r = h / 2
        
        path.addArc(center: CGPoint(x: r, y: r), radius: r, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
        
        path.move(to: CGPoint(x: w, y: 0))
        path.addLine(to: CGPoint(x: r, y: 0))
        path.addLine(to: CGPoint(x: r, y: h))
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
    }
}

