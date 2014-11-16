//
//  FilePreviewCell.swift
//  JSONExport
//
//  Created by Ahmed on 11/10/14.
//  Copyright (c) 2014 Ahmed Ali. All rights reserved.
//

import Cocoa

class FilePreviewCell: NSTableCellView, NSTextViewDelegate {

    
    @IBOutlet weak var classNameLabel: NSTextFieldCell!
    
    
    
    var file: FileRepresenter!{
        didSet{
            if file != nil{
                classNameLabel.stringValue = file.className
                textView.string = file.toString()
                if file.includeConstructors{
                    constructors.state = NSOnState
                }else{
                    constructors.state = NSOffState
                }
                if file.includeUtilities{
                    utilities.state = NSOnState
                }else{
                    utilities.state = NSOffState
                }
            }else{
                classNameLabel.stringValue = ""
            }
        }
    }
    
    @IBOutlet weak var constructors: NSButton!
    
    @IBOutlet weak var utilities: NSButton!
    @IBOutlet var textView: NSTextView!
    
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if textView != nil{
            textView.delegate = self
            setupNumberedTextView()
        }
    }
    
    func setupNumberedTextView()
    {
        let lineNumberView = NoodleLineNumberView(scrollView: scrollView)
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler = true
        scrollView.verticalRulerView = lineNumberView
        scrollView.rulersVisible = true
        textView.font = NSFont.userFixedPitchFontOfSize(NSFont.smallSystemFontSize())
        
    }
    
    @IBAction func toggleConstructors(sender: NSButtonCell)
    {
        if file != nil{
            file.includeConstructors = (sender.state == NSOnState)
            textView.string = file.toString()
            
        }
    }
    
    @IBAction func toggleUtilityMethods(sender: NSButtonCell)
    {
        if file != nil{
            file.includeUtilities = (sender.state == NSOnState)
            textView.string = file.toString()
        }
    }
    
    func textDidChange(notification: NSNotification) {
        file.fileContent = textView.string ?? file.fileContent
    }
    
    
}
