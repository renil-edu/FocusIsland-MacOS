//
//  FloatingWindow.swift
//  FocusIsland
//
//  Created by UT Austin on 8/2/25.
//

import Cocoa
import SwiftUI

class FloatingWindow: NSWindow {

    init(contentView: NSView) {
        guard let screen = NSScreen.main else {
            super.init(contentRect: NSRect(x: 0, y: 0, width: 360, height: 80),
                       styleMask: [.borderless],
                       backing: .buffered,
                       defer: false)
            self.contentView = contentView
            self.isOpaque = false
            self.backgroundColor = NSColor.black.withAlphaComponent(0.85)
            self.level = .statusBar
            self.hasShadow = true
            self.ignoresMouseEvents = false
            self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            return
        }

        let screenFrame = screen.frame

        // Window size
        let width: CGFloat = 360
        let height: CGFloat = 80

        // Horizontally center on full screen width
        let notchCenterX = screenFrame.width / 2
        let xPos = notchCenterX - (width / 2) + 62.5

        // Vertically position overlapping and centered on the menu bar / notch area
        // Adjust yPos to overlap window height/2 over menu bar (y=screen height is top edge)
        let yPos = screenFrame.height - (height / 2) - 50

        let frame = NSRect(x: xPos, y: yPos, width: width, height: height)

        super.init(contentRect: frame,
                   styleMask: [.borderless],
                   backing: .buffered,
                   defer: false)

        self.contentView = contentView

        self.isOpaque = false
        self.backgroundColor = NSColor.black.withAlphaComponent(0.85)

        // Change level from floating to statusBar (above menu bar)
        self.level = .statusBar

        self.hasShadow = true
        self.ignoresMouseEvents = false

        // Let window appear in all spaces and avoid cycling with cmd-tab
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]

        self.setIsVisible(true)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    func reposition() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let width: CGFloat = 360
        let height: CGFloat = 80

        let notchCenterX = screenFrame.width / 2
        let xPos = notchCenterX - (width / 2)
        let yPos = screenFrame.height - (height / 2)

        self.setFrame(NSRect(x: xPos, y: yPos, width: width, height: height), display: true)
    }
}
