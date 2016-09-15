//
//  NetworkRequestWindowController.swift
//  JSONExport
//
//  Created by king on 16/9/15.
//  Copyright © 2016年 Ahmed Ali. All rights reserved.
//

import Cocoa

class NetworkRequestWindowController: NSWindowController {

   override var windowNibName: String? {
        
        return "\(type(of: self))"
    }
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        contentViewController = NetworkRequestViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose), name: NSNotification.Name(rawValue: "NSWindowWillCloseNotification"), object: nil)
        
        
    }
    
    func windowWillClose() {

        NSApplication.shared().stopModal()
    }
    
    deinit {

        NotificationCenter.default.removeObserver(self)
    }
}
