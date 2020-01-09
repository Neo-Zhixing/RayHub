//
//  RouteViewController.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/10/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

enum RouteDomainTypes: Int {
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
class RouteDomain: NSObject {
    weak var controller: RouteViewController!
    @objc var _type: Int {
        didSet {
            controller.updateDomainsString()
        }
    }
    var type: RouteDomainTypes {
        get {
            return RouteDomainTypes(rawValue: self._type)!
        }
        set {
            self._type = newValue.rawValue
        }
    }
    @objc var value: String {
        didSet {
            controller.updateDomainsString()
        }
    }
    
    init(_ value: String, type: RouteDomainTypes) {
        self._type = type.rawValue
        self.value = value
        super.init()
    }
    override init() {
        self._type = 0
        self.value = ""
        super.init()
    }
}
class RouteViewController: NSViewController {
    @objc var domains: [RouteDomain] = [] {
        didSet {
            for domain in domains {
                domain.controller = self
            }
            self.updateDomainsString()
        }
    }
    override func viewDidLoad() {
        let route = self.representedObject as! Route
        
        let domainStrs: [Substring] = route.domains.split(separator: "\n")
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
        self.setValue(domains, forKey: "domains")
    }
    func updateDomainsString() {
        let route = self.representedObject as! Route
        let routeStr = self.domains.map {
            domain in domain.type.prefix + domain.value
        }.joined(separator: "\n")
        route.setValue(routeStr, forKey: "domains")
    }
}
