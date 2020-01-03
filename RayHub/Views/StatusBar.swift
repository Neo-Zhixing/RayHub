//
//  StatusBar.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/4/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import AppKit


class StatusBar: NSTextField {
    var progress: Float = 1 {
        didSet {
            self.needsDisplay = true
        }
    }
    required init?(coder: NSCoder) {
        self.progress = coder.decodeFloat(forKey: "StatusBarProgress")
        super.init(coder: coder)
    }
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(self.progress, forKey: "StatusBarProgress")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Draw progress
        var progressRect = CGRect()
        let height: CGFloat = 4
        progressRect.origin.y = self.bounds.size.height - height - 2
        progressRect.size.height = height
        progressRect.size.width = self.bounds.size.width
        print(self.bounds,self.frame)
        print(progressRect.origin, progressRect.size)

        NSColor.controlAccentColor.set()
        progressRect.fill(using: NSCompositingOperation.sourceIn)
    }
}
