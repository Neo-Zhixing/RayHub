//
//  Route+CoreDataProperties.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/10/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//
//

import Foundation
import CoreData


public enum RouteDomainTypes: Int {
    case contains = 0
    case regex = 1
    case subdomain = 2
    case exact = 3
    case preset = 4
    case file = 5
    
    var prefix: String {
        get {
            switch self {
            case .contains: return ""
            case .regex: return "regexp:"
            case .subdomain: return "domain:"
            case .exact: return "full:"
            case .preset: return "geosite:"
            case .file: return "ext:"
            }
        }
    }
}
public class RouteDomain: NSObject {
    @objc var _type: Int
    var type: RouteDomainTypes {
        get {
            return RouteDomainTypes(rawValue: self._type)!
        }
        set {
            self._type = newValue.rawValue
        }
    }
    @objc var value: String
    
    init(_ value: String, type: RouteDomainTypes) {
        self._type = type.rawValue
        self.value = value
        super.init()
    }
    override init() {
        self._type = 0
        self.value = "example.com"
        super.init()
    }
}



public enum RouteIPTypes: Int {
    case ip = 0
    case preset = 1
    case file = 2
    
    var prefix: String {
        get {
            switch self {
            case .ip: return ""
            case .preset: return "geoip:"
            case .file: return "ext:"
            }
        }
    }
}

public class RouteIP: NSObject {
    @objc var _type: Int
    var type: RouteIPTypes {
        get {
            return RouteIPTypes(rawValue: self._type)!
        }
        set {
            self._type = newValue.rawValue
        }
    }
    @objc var value: String
    
    init(_ value: String, type: RouteIPTypes) {
        self._type = type.rawValue
        self.value = value
        super.init()
    }
    override init() {
        self._type = 1
        self.value = "0.0.0.0/0"
        super.init()
    }
}


public class PortRange: NSObject, NSCopying {
    var start: UInt16
    var end: UInt16
    
    var string: String {
        get {
            return "\(start)-\(end)"
        }
    }
    init(_ start: UInt16, _ end: UInt16) {
        if start < end {
            self.end = end
            self.start = start
        } else {
            self.start = end
            self.end = start
        }
    }
    init? <T>(_ str: T) where T: StringProtocol {
        let vals = str.split(separator: "-")
        if vals.count == 1 {
            if let ip = UInt16(vals[0]) {
                self.start = ip
                self.end = ip
                return
            } else {
                return nil
            }
        }
        if vals.count != 2 {
            return nil
        }
        guard let start = UInt16(vals[0]), let end = UInt16(vals[1]) else {
            return nil
        }
        if start > end {
            return nil
        }
        self.start = start
        self.end = end
        
    }
    override init() {
        self.start = 8000
        self.end = 9000
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        return PortRange(self.start, self.end)
    }
    
    override public func setValue(_ value: Any?, forKey key: String) {
        if key == "self" {
            if let range = value as? PortRange {
                self.start = range.start
                self.end = range.end
                return
            }
        }
        super.setValue(value, forKey: key)
    }
}


@objc(Route)
public class Route: NSManagedObject {

}

extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var domains: String
    @NSManaged public var ips: String
    @NSManaged public var name: String
    @NSManaged public var network: Int16
    @NSManaged public var ports: String
    @NSManaged public var protocols: Int16
    @NSManaged public var sources: String

}

extension Route {
    func domainObjectsUpdate(_ domainObjects: [RouteDomain]) {
        self.domains = domainObjects.map {
            domain in domain.type.prefix + domain.value
        }.joined(separator: "\n")
    }
    @objc public var domainObjects: [RouteDomain] {
        get {
            let domainStrs: [Substring] = self.domains.split(separator: "\n")
            let domains = domainStrs.map {
                    substring -> RouteDomain in
                    let type: RouteDomainTypes
                    if substring.starts(with: RouteDomainTypes.regex.prefix) {
                        type = .regex
                    } else if substring.starts(with: RouteDomainTypes.subdomain.prefix) {
                        type = .subdomain
                    } else if substring.starts(with: RouteDomainTypes.exact.prefix) {
                        type = .exact
                    } else if substring.starts(with: RouteDomainTypes.preset.prefix) {
                        type = .preset
                    } else if substring.starts(with: RouteDomainTypes.file.prefix) {
                        type = .file
                    } else {
                        type = .contains
                    }
                    let content = substring.dropFirst(type.prefix.count)
                    return RouteDomain(String(content), type: type)
            }
            return domains
        }
        set (domainObjects) {
            self.domainObjectsUpdate(domainObjects)
        }
    }
    
    func ipObjectsUpdate(_ ipObjects: [RouteIP]) {
        self.ips = ipObjects.map {
            ip in ip.type.prefix + ip.value
        }.joined(separator: "\n")
    }
    @objc public var ipObjects: [RouteIP] {
        get {
            let ipStrs: [Substring] = self.ips.split(separator: "\n")
            return ipStrs.map {
                    substring -> RouteIP in
                    let type: RouteIPTypes
                    if substring.starts(with: RouteIPTypes.preset.prefix) {
                        type = .preset
                    } else if substring.starts(with: RouteIPTypes.file.prefix) {
                        type = .file
                    } else {
                        type = .ip
                    }
                    let content = substring.dropFirst(type.prefix.count)
                    return RouteIP(String(content), type: type)
            }
        }
        set (ipObjects) {
            self.ipObjectsUpdate(ipObjects)
        }
    }
    
    func portObjectsUpdate(_ portObjects: [PortRange]) {
        self.ports = portObjects.map{ port in port.string }.joined(separator: ",")
    }
    @objc public var portObjects: [PortRange] {
        get {
            let portStrs: [Substring] = self.ports.split(separator: ",")
            return portStrs
                .compactMap{ port -> PortRange? in PortRange(port)}
        }
        set(portObjects) {
            self.portObjectsUpdate(portObjects)
        }
    }
}
