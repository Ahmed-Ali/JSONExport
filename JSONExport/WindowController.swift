//
//  WindowController.swift
//  JSONExport
//
//  Created by king on 16/9/2.
//  Copyright © 2016年 Ahmed Ali. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        (NSApplication.sharedApplication().delegate as! AppDelegate).window = window
    }

}
