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


extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var domains: String
    @NSManaged public var ips: String
    @NSManaged public var name: String
    @NSManaged public var network: Int16
    @NSManaged public var ports: String
    @NSManaged public var protocols: String
    @NSManaged public var sources: String

}
