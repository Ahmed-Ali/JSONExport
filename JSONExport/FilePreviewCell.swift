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

    var file: FileRepresenter! {
        didSet {
            if file != nil {
                DispatchQueue.main.async {
                    var fileName = self.file.className
                    fileName += "."
                    if self.file is HeaderFileRepresenter {
                        fileName += self.file.lang.headerFileData.headerFileExtension
                    } else {
                        fileName += self.file.lang.fileExtension
                    }
                    self.classNameLabel.stringValue = fileName
                    if(self.textView != nil) {
                        self.textView.string = self.file.toString()
                    }

                    if self.file.includeConstructors {
                        self.constructors.state = NSControl.StateValue.on
                    } else {
                        self.constructors.state = NSControl.StateValue.off
                    }
                    if self.file.includeUtilities {
                        self.utilities.state = NSControl.StateValue.on
                    } else {
                        self.utilities.state = NSControl.StateValue.off
                    }
                }
            } else {
                classNameLabel.stringValue = ""
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if textView != nil {
            textView.delegate = self
            DispatchQueue.main.async {
                self.setupNumberedTextView()
            }
        }
    }

    func setupNumberedTextView() {
        let lineNumberView = NoodleLineNumberView(scrollView: scrollView)
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler = true
        scrollView.verticalRulerView = lineNumberView
        scrollView.rulersVisible = true
        textView.font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize)

    }

    @IBAction func toggleConstructors(_ sender: NSButtonCell) {
        if file != nil {
            file.includeConstructors = (sender.state == NSControl.StateValue.off)
            textView.string = file.toString()

        }
    }

    @IBAction func toggleUtilityMethods(_ sender: NSButtonCell) {
        if file != nil {
            file.includeUtilities = (sender.state == NSControl.StateValue.on)
            textView.string = file.toString()
        }
    }

    func textDidChange(_ notification: Notification) {
		file.fileContent = textView.string
    }
}
