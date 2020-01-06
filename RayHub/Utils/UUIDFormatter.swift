//
//  UUIDFormatter.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/6/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit

class UUIDFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        if let uuid = obj as? UUID {
            return uuid.uuidString
        }
        return nil
    }
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let uuid = UUID(uuidString: string) {
            obj?.pointee = uuid as AnyObject
            return true
        } else {
            error?.pointee = "Invalid UUID string"
            return false
        }
    }
}
