//
//  WindowController.swift
//  JSONExport
//
//  Created by king on 16/9/2.
//  Copyright © 2016年 Ahmed Ali. All rights reserved.
//

import Cocoa

public let NetworkRequestDataNotification = "NetworkRequestDataNotification"
public let NetworkRequestDataKey = "NetworkRequestDataKey"

class WindowController: NSWindowController {

 
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        (NSApplication.shared().delegate as! AppDelegate).window = window
        
        if let menu =  NSApplication.shared().mainMenu?.item(at: 0) {
            for item in menu.submenu!.items {
                if item.title == "Network Request" {

                    item.target = self
                    item.action = #selector(networkRequest)
                }
            }
        }
    }
    
    func networkRequest() {
        
        NSApplication.shared().runModal(for: NetworkRequestWindowController().window!)
    }

}
