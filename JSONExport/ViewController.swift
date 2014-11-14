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
let langContentKey = "langContent"

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
    var langs : [NSDictionary] = [NSDictionary]()
    @IBOutlet weak var languagesPopup: NSPopUpButton!
    
    
    var files : [FileRepresenter] = [FileRepresenter]()
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.enabled = false
        setPreDefinedData()
        setupNumberedTextView()
        setLanguagesSelection()
        updateUIFieldsForSelectedLanguage()
    }
    
    
    func setLanguagesSelection()
    {
        langs = NSUserDefaults.standardUserDefaults().arrayForKey(supportedLanguagesKeyForUserDefaults) as [NSDictionary]
        var langNames = [String]()
        for lang in langs{
            let langName = lang[langNameKey] as String
            langNames.append(langName)
        }
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
            firstLineField.hidden = true
            firstLineField.placeholderString = selectedLang.firstLineHint
        }else{
            firstLineField.hidden = true
        }
    }
    
    //MARK: - Handling pre defined languages
    func setPreDefinedData()
    {
        if isFirstTypeTheAppRun(){
            loadPreDefinedData()
            markTheAppAsRunBefore()
        }
    }
    
    func isFirstTypeTheAppRun() -> Bool
    {
        return true//!NSUserDefaults.standardUserDefaults().boolForKey("appFirstRun")
    }
    
    func markTheAppAsRunBefore()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "appFirstRun")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func loadPreDefinedData()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        var loadedLangs = [NSDictionary]()
        if let langFiles = NSBundle.mainBundle().URLsForResourcesWithExtension("json", subdirectory: nil) as? [NSURL]{
            for langFile in langFiles{
                if let langContent = String(contentsOfURL: langFile, encoding: NSUTF8StringEncoding, error: nil){
                    if let langDictionary = NSJSONSerialization.JSONObjectWithData(langContent.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options: .allZeros, error: nil) as? NSDictionary{
                        let lang = LangModel(fromDictionary: langDictionary)
                        langs.append([langNameKey : lang.displayLangName, langContentKey : langDictionary])
                        println("successfully added lang: \(lang.displayLangName)")
                    }
                    
                }
                
            }
        }
        
        defaults.setObject(langs, forKey:supportedLanguagesKeyForUserDefaults)
        defaults.synchronize()
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
        generateClasses();
    }
    
    
    @IBAction func firstLineChanged(sender: AnyObject) {
    }
    
    //MARK: - NSTextDelegate
    
    func textDidChange(notification: NSNotification) {
        generateClasses()
    }
    
    

    
    
    
    
    //MARK: - Language selection handling
    func loadSelectedLanguageModel()
    {
        if let langData = langDataForLangName(selectedLanguageName){
            selectedLang = LangModel(fromDictionary: langData)
        }
        
        
    }
    
    func langDataForLangName(langName: String) -> NSDictionary?
    {
        for data in langs{
            let loadedLangName = data[langNameKey] as String
            if loadedLangName == langName{
                if let langData = data[langContentKey] as? NSDictionary{
                    return langData
                }
               
            }
           
        }
        
        
        return nil
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
                addFileWithName(rootClassName, jsonObject:json)
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
    
    
    
    func addFileWithName(var className: String, jsonObject: NSDictionary){
        var properties = [Property]()
        let prefix = classPrefixField.stringValue
        if countElements(prefix) > 0{
            if !className.hasPrefix(prefix){
                className = "\(prefix)\(className)"
            }
        }
        
        var jsonProperties = sorted(jsonObject.allKeys as [String])
        
        for jsonPropertyName in jsonProperties{
            
            let swiftPropertyName = propertySwiftName(jsonPropertyName)
            
            let value : AnyObject = jsonObject[jsonPropertyName]!
            
            var type = propertyTypeName(value)
            
            var isDictionary = false
            var isArray = false
            
            if value is NSDictionary {
                let leafClassName = classNameForPropertyName(jsonPropertyName)
                addFileWithName(leafClassName, jsonObject: value as NSDictionary)
                type = leafClassName
                properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, isArray: false, isCustomClass: true, lang:selectedLang))
            }else if value is NSArray{
                //we need to check its elements...
                let array = value as NSArray
                if let dic = array.firstObject? as? NSDictionary{
                    //wow complicated
                    let leafClassName = classNameForPropertyName(jsonPropertyName)
                    addFileWithName(leafClassName, jsonObject: dic)
                    type = selectedLang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: leafClassName)
                    
                    properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, isArray: true, isCustomClass: false, lang:selectedLang))
                }else{
                    properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, isArray: true, isCustomClass: false, lang:selectedLang))
                }
            }else{
                properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, lang:selectedLang))
            }
            
            
        }
        
        let includeConstructs = generateConstructors.state == NSOnState
        let includeUtilities = generateUtilityMethods.state == NSOnState
        let file = FileRepresenter(className: className, properties: properties, lang:selectedLang)
        file.includeUtilities = includeUtilities
        file.includeConstructors = includeConstructs
        files.append(file)
    }
    
    
    func propertySwiftName(jsonName : String) -> String
    {
        return underscoresToCamelCaseForString(jsonName, startFromFirstChar: false)
    }
    
    func underscoresToCamelCaseForString(input: String, startFromFirstChar: Bool) -> String
    {
        var str = input.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        str = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var output = ""
        var makeNextCharUpperCase = startFromFirstChar
        for char in input{
            if char == "_" {
                makeNextCharUpperCase = true
            }else if makeNextCharUpperCase{
                let upperChar = String(char).uppercaseString
                output += upperChar
                makeNextCharUpperCase = false
            }else{
                makeNextCharUpperCase = false
                output += String(char)
            }
        }
        
        return output
    }
    
    
    
    func classNameForPropertyName(propertyName : String) -> String{
        var swiftClassName = underscoresToCamelCaseForString(propertyName, startFromFirstChar: true).toSingular()
        let prefix = classPrefixField.stringValue
        if countElements(prefix) > 0{
            if !swiftClassName.hasPrefix(prefix){
                swiftClassName = "\(prefix)\(swiftClassName)"
            }
        }
        return swiftClassName
    }
    
    func propertyTypeName(value : AnyObject) -> String
    {
        var name = ""
        if value is NSArray{
            name = typeNameForArrayElements(value as NSArray)
        }else if value is NSNumber{
            name = typeForNumber(value as NSNumber)
        }else if value is NSString{
            let booleans : [String] = ["True", "true", "TRUE", "False", "false", "FALSE"]
            if find(booleans, value as String) != nil{
                name = selectedLang.dataTypes.boolType
            }else{
                name = selectedLang.dataTypes.stringType
            }
            
        }
        
        return name
    }
    
    
    func typeNameForArrayElements(elements: NSArray) -> String{
        var typeName : String!
        let genericType = selectedLang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: selectedLang.genericType)
        if elements.count == 0{
            typeName = genericType
            
        }
        for element in elements{
            let currElementTypeName = propertyTypeName(element)
            
            let arrayTypeName = selectedLang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: currElementTypeName)
            
            if typeName == nil{
                typeName = arrayTypeName
                
            }else{
                if typeName != arrayTypeName{
                    typeName = genericType
                    break
                }
            }
        }
        
        return typeName
    }
    
    
    func typeForNumber(number : NSNumber) -> NSString
    {
        let numberType = CFNumberGetType(number as CFNumberRef)
        
        var typeName : String!
        switch numberType{
        case .CharType:
            if (number.intValue == 0 || number.intValue == 1){
                //it seems to be boolean
                typeName = selectedLang.dataTypes.boolType
            }else{
                typeName = selectedLang.dataTypes.characterType
            }
        case .ShortType, .IntType:
            typeName = selectedLang.dataTypes.intType
        case .FloatType:
            typeName = selectedLang.dataTypes.floatType
        case .DoubleType:
            typeName = selectedLang.dataTypes.doubleType
        case .LongType, .LongLongType:
            typeName = selectedLang.dataTypes.longType
        default:
            typeName = selectedLang.dataTypes.intType
        }
        
        return typeName
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

