//
//  ViewController.swift
//  JSONExport
//
//  Created by Ahmed on 11/2/14.
//  Copyright (c) 2014 Ahmed Ali. Eng.Ahmed.Ali.Awad@gmail.com.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the contributor can not be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Cocoa


let supportedLanguagesKeyForUserDefaults = "supportedLangs"
let langNameKey = "langName"
let theLangKey = "theLang"

class ViewController: NSViewController, NSUserNotificationCenterDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    
    @IBOutlet weak var statusTextField: NSTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet var sourceText: NSTextView!
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var generateConstructors: NSButtonCell!
    
    @IBOutlet weak var generateUtilityMethods: NSButtonCell!
    
    @IBOutlet weak var classNameField: NSTextFieldCell!
    
    @IBOutlet weak var classPrefixField: NSTextField!
    
    
    @IBOutlet weak var firstLineField: NSTextField!
    
   

    var selectedLang : LangModel!
    var selectedLanguageName : String
        {
        return languagesPopup.titleOfSelectedItem!
    }
    var langs : [String : LangModel] = [String : LangModel]()
    @IBOutlet weak var languagesPopup: NSPopUpButton!
    
    
    var files : [FileRepresenter] = [FileRepresenter]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        loadSupportedLanguages()
        setupNumberedTextView()
        setLanguagesSelection()
        updateUIFieldsForSelectedLanguage()
    }
    
    
    func setLanguagesSelection()
    {
        let langNames = sorted(langs.keys.array)
        
        languagesPopup.removeAllItems()
        languagesPopup.addItemsWithTitles(langNames)
        
    }
    
    func setupNumberedTextView()
    {
        let lineNumberView = NoodleLineNumberView(scrollView: scrollView)
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler = true
        scrollView.verticalRulerView = lineNumberView
        scrollView.rulersVisible = true
        sourceText.font = NSFont.userFixedPitchFontOfSize(NSFont.smallSystemFontSize())
        
    }
    
    func updateUIFieldsForSelectedLanguage()
    {
        loadSelectedLanguageModel()
        if selectedLang.supportsFirstLineStatement != nil && selectedLang.supportsFirstLineStatement!.boolValue{
            firstLineField.hidden = false
            firstLineField.placeholderString = selectedLang.firstLineHint
        }else{
            firstLineField.hidden = true
        }
    }
    
    //MARK: - Handling pre defined languages
    func loadSupportedLanguages()
    {
       
        if let langFiles = NSBundle.mainBundle().URLsForResourcesWithExtension("json", subdirectory: nil) as? [NSURL]{
            for langFile in langFiles{
                if let langContent = String(contentsOfURL: langFile, encoding: NSUTF8StringEncoding, error: nil){
                    if let langDictionary = NSJSONSerialization.JSONObjectWithData(langContent.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: .allZeros, error: nil) as? NSDictionary{
                        let lang = LangModel(fromDictionary: langDictionary)
                        langs[lang.displayLangName] = lang

                        
                    }
                    
                }
                
            }
        }
        
    }

    
    
    //MARK: - Handlind events
    
    @IBAction func toggleConstructors(sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func toggleUtilities(sender: AnyObject)
    {
        generateClasses()
    }
    
    @IBAction func rootClassNameChanged(sender: AnyObject) {
        generateClasses()
    }
    
    
    @IBAction func classPrefixChanged(sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func selectedLanguageChanged(sender: AnyObject)
    {
        updateUIFieldsForSelectedLanguage()
        generateClasses();
    }
    
    
    @IBAction func firstLineChanged(sender: AnyObject)
    {
        generateClasses()
    }
    
    //MARK: - NSTextDelegate
    
    func textDidChange(notification: NSNotification) {
        generateClasses()
    }
    
    

    
    
    
    
    //MARK: - Language selection handling
    func loadSelectedLanguageModel()
    {
        selectedLang = langs[selectedLanguageName]
        
    }
    
    
    
    
    //MARK: - NSUserNotificationCenterDelegate
    func userNotificationCenter(center: NSUserNotificationCenter,
        shouldPresentNotification notification: NSUserNotification) -> Bool
    {
        return true
    }
    
    //MARK: - Showing the open panel and save files
    @IBAction func saveFiles(sender: AnyObject)
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsOtherFileTypes = false
        openPanel.treatsFilePackagesAsDirectories = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Choose"
        openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: { (button : Int) -> Void in
            if button == NSFileHandlingPanelOKButton{
                
                self.saveToPath(openPanel.URL!.path!)
                
                self.showDoneSuccessfully()
            }
        })
    }

    
    
    func saveToPath(path : String)
    {
        let fileManager = NSFileManager.defaultManager()
        var error : NSError?
        
        for file in files{
            let fileContent = file.stringContent
            let filePath = "\(path)/\(file.className).\(selectedLang.fileExtension)"
            
            fileContent.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding, error: &error)
            if error != nil{
                showError(error!)
                break
            }
            
        }
    }
    
    //MARK: - Messages
    func showDoneSuccessfully()
    {
        let notification = NSUserNotification()
        notification.title = "Success!"
        notification.informativeText = "Your \(selectedLang.langName) model files have been generated successfully."
        notification.identifier = "\(selectedLang.langName)Files"
        notification.deliveryDate = NSDate()

        let center = NSUserNotificationCenter.defaultUserNotificationCenter()
        center.delegate = self
        center.deliverNotification(notification)
    }
    func showError(error: NSError!)
    {
        if error == nil{
            return;
        }
        let alert = NSAlert(error: error)
        alert.runModal()
    }
    
    func showErrorStatus(errorMessage: String)
    {

        statusTextField.textColor = NSColor.redColor()
        statusTextField.stringValue = errorMessage
    }
    
    func showSuccessStatus(successMessage: String)
    {
        
        statusTextField.textColor = NSColor.greenColor()
        statusTextField.stringValue = successMessage
    }
    
    //MARK: - Generate files content
    func generateClasses()
    {
        saveButton.enabled = false
        let str = sourceText.string!
        if countElements(str) == 0{
            //Nothing to do
            return;
        }
        var rootClassName = classNameField.stringValue
        let prefix = classPrefixField.stringValue
        if countElements(rootClassName) == 0{
            rootClassName = "RootClass"
        }
        
    
        if let data = str.dataUsingEncoding(NSUTF8StringEncoding){
            var error : NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &error) as? NSDictionary{
                loadSelectedLanguageModel()
                files.removeAll(keepCapacity: false)
                let fileGenerator = prepareAndGetFileGenerator()
                fileGenerator.addFileWithName(rootClassName, jsonObject: json, files: &files)
                
                
                showSuccessStatus("Valid JSON structure")
                saveButton.enabled = true
                files = reverse(files)
                tableView.reloadData()
            }else{
                saveButton.enabled = false
                if error != nil{
                    println(error)
                }
                showErrorStatus("It seems your JSON object is not valid!")
                
            }
        }
    }
    
    func prepareAndGetFileGenerator() -> FileGenerator
    {
        let fileGenerator = FileGenerator.instance
        fileGenerator.includeConstructs = (generateConstructors.state == NSOnState)
        fileGenerator.includeUtilities = (generateUtilityMethods.state == NSOnState)
        fileGenerator.firstLine = firstLineField.stringValue
        fileGenerator.lang = selectedLang
        fileGenerator.classPrefix = classPrefixField.stringValue
        return fileGenerator
    }
    
    
    
    
    //MARK: - NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return files.count
    }
    
    
    //MARK: - NSTableViewDelegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView
    {
        let cell = tableView.makeViewWithIdentifier("fileCell", owner: self) as FilePreviewCell
        let file = files[row]
        cell.file = file
        
        return cell
    }
   

    
}

