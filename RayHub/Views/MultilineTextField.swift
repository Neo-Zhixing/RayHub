//
//  MultilineTextField.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/10/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import SwiftUI

public class DynamicTextField: NSTextField {
   public override var intrinsicContentSize: NSSize {
      if cell!.wraps {
         let fictionalBounds = NSRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
         return cell!.cellSize(forBounds: fictionalBounds)
      } else {
         return super.intrinsicContentSize
      }
   }

   public override func textDidChange(_ notification: Notification) {
      super.textDidChange(notification)

      if cell!.wraps {
         validateEditing()
         invalidateIntrinsicContentSize()
      }
   }
}

struct MultilineTextField: NSViewRepresentable {
    @Binding var text: String
    func makeNSView(context: Context) -> DynamicTextField {
        let textField = DynamicTextField()
        textField.lineBreakMode = .byCharWrapping
        textField.isBordered = true
        textField.target = context.coordinator
        textField.delegate = context.coordinator
        textField.action = #selector(context.coordinator.update(sender:))
        textField.usesSingleLineMode = false
        textField.maximumNumberOfLines = 0
        textField.autoresizingMask = [.height, .width, .maxXMargin, .maxYMargin, .minXMargin, .minYMargin]
        return textField
    }

    /// Updates the presented `NSView` (and coordinator) to the latest
    /// configuration.
    func updateNSView(_ nsView: DynamicTextField, context: Context) {
        nsView.stringValue = self.text
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        let textField: MultilineTextField
        init(_ textField: MultilineTextField) {
            self.textField = textField
        }
        @objc func update(sender: NSTextField) {
            self.textField.text = sender.stringValue
        }
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(textView.insertNewline(_:)) {
                textView.insertNewlineIgnoringFieldEditor(self)
                self.textField.text = textView.string
                return true
            }
            return false
        }
        func controlTextDidEndEditing(_ obj: Notification) {
            let textView = obj.userInfo!["NSFieldEditor"] as! NSTextView
            self.textField.text = textView.string
            
        }
    }
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
