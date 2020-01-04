//
//  HostnameComboBoxController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/5/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

class HostnameComboBoxController: NSObject, NSComboBoxDataSource {
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.localAddress.count
    }
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return self.localAddress[index]
    }

    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        for (i, str) in self.localAddress.enumerated() {
            if str == string {
                return i
            }
        }
        return -1
    }
    lazy var localAddress: [String] = {
        var address: [String] = [
            "0.0.0.0",
            "localhost"
        ]

        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr!.pointee.ifa_next }

                let interface = ptr!.pointee

                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address.append(String(cString: hostname))
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }()
}
