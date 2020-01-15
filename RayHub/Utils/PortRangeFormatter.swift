//
//  IPRangeFormatter.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/10/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import Foundation

class PortRangeFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        if let iprange = obj as? PortRange {
            return iprange.string
        }
        return nil
    }
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if let iprange = PortRange(string) {
            obj?.pointee = iprange as AnyObject
            return true
        } else {
            error?.pointee = "Invalid IPRange string"
            return false
        }
    }
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let trimedStr = partialString.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789-").inverted)
        if trimedStr.count != partialString.count {
            newString?.pointee = trimedStr as NSString
            error?.pointee = "Contains invalid characters! Only 0-9 and '-' are allowed."
            return false
        }
        return true
    }
}
