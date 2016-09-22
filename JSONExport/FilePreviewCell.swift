//
//  FilePreviewCell.swift
//  JSONExport
//
//  Created by Ahmed on 11/10/14.
//  Copyright (c) 2014 Ahmed Ali. All rights reserved.
//

import Cocoa

class FilePreviewCell: NSTableCellView, NSTextViewDelegate {

    
    @IBOutlet var classNameLabel: NSTextFieldCell!
    @IBOutlet var constructors: NSButton!
    @IBOutlet var utilities: NSButton!
    @IBOutlet var textView: NSTextView!
    @IBOutlet var scrollView: NSScrollView!
    
    
    var file: FileRepresenter!{
        didSet{
            if file != nil{
                var fileName = file.className
                fileName += "."
                if file is HeaderFileRepresenter{
                    fileName += file.lang.headerFileData.headerFileExtension
                }else{
                    fileName += file.lang.fileExtension
                }
                classNameLabel.stringValue = fileName
                if(textView != nil){
                    textView.string = file.toString()
                }
                
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
        textView.font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize())
        
    }
    
    @IBAction func toggleConstructors(_ sender: NSButtonCell)
    {
        if file != nil{
            file.includeConstructors = (sender.state == NSOnState)
            textView.string = file.toString()
            
        }
    }
    
    @IBAction func toggleUtilityMethods(_ sender: NSButtonCell)
    {
        if file != nil{
            file.includeUtilities = (sender.state == NSOnState)
            textView.string = file.toString()
        }
    }
    
    func textDidChange(_ notification: Notification) {
        file.fileContent = textView.string ?? file.fileContent
    }
    
    
}
