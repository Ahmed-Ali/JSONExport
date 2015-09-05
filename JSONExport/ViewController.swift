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

class ViewController: NSViewController, NSUserNotificationCenterDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextViewDelegate {
    
    //Shows the list of files' preview
    @IBOutlet weak var tableView: NSTableView!
    
    //Connected to the top right corner to show the current parsing status
    @IBOutlet weak var statusTextField: NSTextField!
    
    //Connected to the save button
    @IBOutlet weak var saveButton: NSButton!
    
    //Connected to the JSON input text view
    @IBOutlet var sourceText: NSTextView!
    
    //Connected to the scroll view which wraps the sourceText
    @IBOutlet weak var scrollView: NSScrollView!
    
    //Connected to Constructors check box
    @IBOutlet weak var generateConstructors: NSButtonCell!
    
    //Connected to Utility Methods check box
    @IBOutlet weak var generateUtilityMethods: NSButtonCell!
    
    //Connected to root class name field
    @IBOutlet weak var classNameField: NSTextFieldCell!
    
    //Connected to parent class name field
    @IBOutlet weak var parentClassName: NSTextField!
    
    //Connected to class prefix field
    @IBOutlet weak var classPrefixField: NSTextField!
    
    //Connected to the first line statement field
    @IBOutlet weak var firstLineField: NSTextField!
    
    //Connected to the languages pop up
    @IBOutlet weak var languagesPopup: NSPopUpButton!

    //Holds the currently selected language
    var selectedLang : LangModel!
    
    //Returns the title of the selected language in the languagesPopup
    var selectedLanguageName : String
        {
        return languagesPopup.titleOfSelectedItem!
    }
    
    //Should hold list of supported languages, where the key is the language name and the value is LangModel instance
    var langs : [String : LangModel] = [String : LangModel]()
    
    //Holds list of the generated files
    var files : [FileRepresenter] = [FileRepresenter]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        loadSupportedLanguages()
        setupNumberedTextView()
        setLanguagesSelection()
        updateUIFieldsForSelectedLanguage()
    }
    
    /**
    Sets the values of languagesPopup items' titles
    */
    func setLanguagesSelection()
    {
        let langNames = sorted(langs.keys.array)
        languagesPopup.removeAllItems()
        languagesPopup.addItemsWithTitles(langNames)
        
    }
    
    /**
    Sets the needed configurations for show the line numbers in the input text view
    */
    func setupNumberedTextView()
    {
        let lineNumberView = NoodleLineNumberView(scrollView: scrollView)
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler = true
        scrollView.verticalRulerView = lineNumberView
        scrollView.rulersVisible = true
        sourceText.font = NSFont.userFixedPitchFontOfSize(NSFont.smallSystemFontSize())
        
    }
    
    /**
    Updates the visible fields according to the selected language
    */
    func updateUIFieldsForSelectedLanguage()
    {
        loadSelectedLanguageModel()
        if selectedLang.supportsFirstLineStatement != nil && selectedLang.supportsFirstLineStatement!.boolValue{
            firstLineField.hidden = false
            firstLineField.placeholderString = selectedLang.firstLineHint
        }else{
            firstLineField.hidden = true
        }
        
        if selectedLang.modelDefinitionWithParent != nil || selectedLang.headerFileData?.modelDefinitionWithParent != nil{
            parentClassName.hidden = false
        }else{
            parentClassName.hidden = true
        }
    }
    
    
    
    //MARK: - Handling pre defined languages
    func loadSupportedLanguages()
    {
        if let langFiles = NSBundle.mainBundle().URLsForResourcesWithExtension("json", subdirectory: nil) as? [NSURL]{
            for langFile in langFiles{
                if let data = NSData(contentsOfURL: langFile), langDictionary = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: nil) as? NSDictionary{
                    let lang = LangModel(fromDictionary: langDictionary)
                    if langs[lang.displayLangName] != nil{
                        continue
                    }
                    langs[lang.displayLangName] = lang
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
    
    @IBAction func parentClassNameChanged(sender: AnyObject)
    {
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

    
    /**
    Saves all the generated files in the specified path
    
    :param: path in which to save the files
    */
    func saveToPath(path : String)
    {
        let fileManager = NSFileManager.defaultManager()
        var error : NSError?
        
        for file in files{
            let fileContent = file.fileContent
            var fileExtension = selectedLang.fileExtension
            if file is HeaderFileRepresenter{
                fileExtension = selectedLang.headerFileData.headerFileExtension
            }
            let filePath = "\(path)/\(file.className).\(fileExtension)"
            
            fileContent.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding, error: &error)
            if error != nil{
                showError(error!)
                break
            }
            
        }
    }
    
    
    //MARK: - Messages
    /**
    Shows the top right notification. Call it after saving the files successfully
    */
    func showDoneSuccessfully()
    {
        let notification = NSUserNotification()
        notification.title = "Success!"
        notification.informativeText = "Your \(selectedLang.langName) model files have been generated successfully."
        notification.deliveryDate = NSDate()

        let center = NSUserNotificationCenter.defaultUserNotificationCenter()
        center.delegate = self
        center.deliverNotification(notification)
    }
    
    /**
    Shows an NSAlert for the passed error
    */
    func showError(error: NSError!)
    {
        if error == nil{
            return;
        }
        let alert = NSAlert(error: error)
        alert.runModal()
    }
    
    /**
    Shows the passed error status message
    */
    func showErrorStatus(errorMessage: String)
    {

        statusTextField.textColor = NSColor.redColor()
        statusTextField.stringValue = errorMessage
    }
    
    /**
    Shows the passed success status message
    */
    func showSuccessStatus(successMessage: String)
    {
        
        statusTextField.textColor = NSColor.greenColor()
        statusTextField.stringValue = successMessage
    }
    
    
    
    //MARK: - Generate files content
    /**
    Validates the sourceText string input, and takes any needed action to generate the model classes and view them in the preview panel
    */
    func generateClasses()
    {
        saveButton.enabled = false
        var str = sourceText.string!
        
        if count(str) == 0{
            //Nothing to do, just clear any generated files
            files.removeAll(keepCapacity: false)
            tableView.reloadData()
            return;
        }
        var rootClassName = classNameField.stringValue
        let prefix = classPrefixField.stringValue
        if count(rootClassName) == 0{
            rootClassName = "RootClass"
        }
        sourceText.editable = false
        //Do the lengthy process in background, it takes time with more complicated JSONs
        runOnBackground {
            str = jsonStringByRemovingUnwantedCharacters(str)
            if let data = str.dataUsingEncoding(NSUTF8StringEncoding){
                var error : NSError?
                if let jsonData : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &error){
                    var json : NSDictionary!
                    if jsonData is NSDictionary{
                        //fine nothing to do
                        json = jsonData as! NSDictionary
                    }else{
                        json = unionDictionaryFromArrayElements(jsonData as! NSArray)
                    }
                    self.loadSelectedLanguageModel()
                    self.files.removeAll(keepCapacity: false)
                    let fileGenerator = self.prepareAndGetFilesBuilder()
                    fileGenerator.addFileWithName(&rootClassName, jsonObject: json, files: &self.files)
                    fileGenerator.fixReferenceMismatches(inFiles: self.files)
                    self.files = reverse(self.files)
                    runOnUiThread{
                        self.sourceText.editable = true
                        self.showSuccessStatus("Valid JSON structure")
                        self.saveButton.enabled = true
                        
                        self.tableView.reloadData()
                    }
                }else{
                    runOnUiThread({ () -> Void in
                        self.sourceText.editable = true
                        self.saveButton.enabled = false
                        if error != nil{
                            println(error)
                        }
                        self.showErrorStatus("It seems your JSON object is not valid!")
                    })
                    
                }
            }
        }
    }
    
    /**
    Creates and returns an instance of FilesContentBuilder. It also configure the values from the UI components to the instance. I.e includeConstructors
    
    :returns: instance of configured FilesContentBuilder
    */
    func prepareAndGetFilesBuilder() -> FilesContentBuilder
    {
        let filesBuilder = FilesContentBuilder.instance
        filesBuilder.includeConstructors = (generateConstructors.state == NSOnState)
        filesBuilder.includeUtilities = (generateUtilityMethods.state == NSOnState)
        filesBuilder.firstLine = firstLineField.stringValue
        filesBuilder.lang = selectedLang
        filesBuilder.classPrefix = classPrefixField.stringValue
        filesBuilder.parentClassName = parentClassName.stringValue
        return filesBuilder
    }
    
    
    
    
    //MARK: - NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return files.count
    }
    
    
    //MARK: - NSTableViewDelegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.makeViewWithIdentifier("fileCell", owner: self) as! FilePreviewCell
        let file = files[row]
        cell.file = file
        
        return cell
    }
   

    
}

