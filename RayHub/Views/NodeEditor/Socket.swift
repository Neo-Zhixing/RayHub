//
//  Socket.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/9/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import Foundation

class Socket {
    var name: String
    var identifier: String
    var multiple: Bool
    fileprivate init(name: String, identifier: String, multiple: Bool = false) {
        self.name = name
        self.identifier = identifier
        self.multiple = multiple
    }
}

extension Socket: Hashable {
    static func == (lhs: Socket, rhs: Socket) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func hash(into hasher: inout Hasher) {
        self.identifier.hash(into: &hasher)
    }
}

class InputSocket: Socket {
    override init(name: String, identifier: String, multiple: Bool = false) {
        super.init(name: name, identifier: identifier, multiple: multiple)
    }
}

class OutputSocket: Socket {
    var connections: Set<InputSocket>
    override init(name: String, identifier: String, multiple: Bool = false) {
        self.connections = Set<InputSocket>()
        super.init(name: name, identifier: identifier, multiple: multiple)
    }
    
    func connect(input: InputSocket) -> OutputSocket {
        self.connections.insert(input)
        return self
    }
}
