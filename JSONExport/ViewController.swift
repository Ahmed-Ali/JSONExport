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




class ViewController: NSViewController, NSUserNotificationCenterDelegate {

    let preDefinedLanguages = [
        "Swift-Class"
    ]
    

    var selectedLang : LangModel!
    
    var files : [FileRepresenter] = [FileRepresenter]()
    
    @IBOutlet weak var indicator: NSProgressIndicator!
    
    @IBOutlet var sourceText: NSTextView!
    
    @IBOutlet weak var generateConstructors: NSButtonCell!
    
    @IBOutlet weak var generateUtilityMethods: NSButtonCell!
    
    @IBOutlet weak var classNameField: NSTextFieldCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPreDefinedData()
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
        return true //!NSUserDefaults.standardUserDefaults().boolForKey("appFirstRun")
    }
    
    func markTheAppAsRunBefore()
    {
//        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "appFirstRun")
//        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func loadPreDefinedData()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        var langs = [NSDictionary]()
        for langName in preDefinedLanguages
        {
            let langFilePath = NSBundle.mainBundle().pathForResource(langName, ofType: "json")!
            let langBody = NSString(contentsOfFile:langFilePath, encoding:NSUTF8StringEncoding, error:nil)
            langs.append([langName : langBody!])
        }
        
        defaults.setObject(langs, forKey:"supportedLangs")
        defaults.synchronize()
    }
    
    
    //MARK: - Language selection handling
    func loadSelectedLanguageModel()
    {
        let selectedLanguage = "Swift-Class"
        if let langData = langDataForLangName(selectedLanguage){
            selectedLang = LangModel(fromDictionary: langData)
        }
        
        
    }
    
    func langDataForLangName(langName: String) -> NSDictionary?
    {
        let langs = NSUserDefaults.standardUserDefaults().arrayForKey("supportedLangs") as [NSDictionary]
        var langData : NSDictionary!
        var langStr : String!
        for data in langs{
            langStr = data[langName] as? String
            if langStr != nil{
                var error : NSError?
                if let data = langStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true){
                    langData = NSJSONSerialization.JSONObjectWithData(data, options:.allZeros, error: &error) as? NSDictionary
                    if langData == nil{
                        showError(error)
                    }
                    
                    break;
                }

               
            }
        }
        
       
        
        return langData
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
        let str = sourceText.string! as NSString
        let rootClassName = classNameField.stringValue
        if countElements(rootClassName) == 0{
            showError("Please enter the class name")
            return
        }
        if str.length == 0{
            showError("Please enter your JSON model data")
            return
        }
        showSavePanel()
    }

    
    func showSavePanel()
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsOtherFileTypes = false
        openPanel.treatsFilePackagesAsDirectories = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.beginSheetModalForWindow(self.view.window!, completionHandler: { (button : Int) -> Void in
            if button == NSFileHandlingPanelOKButton{
                self.indicator.startAnimation(nil)
                self.generateClasses()
                self.saveToPath(openPanel.URL!.path!)
                self.indicator.stopAnimation(nil)
                self.showDoneSuccessfully()
            }
        })
    }
    
    func saveToPath(path : String)
    {
        let fileManager = NSFileManager.defaultManager()
        var error : NSError?
        let includeConstructs = generateConstructors.state == NSOnState
        let includeUtilities = generateUtilityMethods.state == NSOnState
        for file in files{
            let fileContent = file.toString(includeConstructors: includeConstructs, includeUtilities: includeUtilities)
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
//        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        //scheduleNotification
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
    
    func showError(errorMessage: String)
    {
        let alert = NSAlert()
        alert.addButtonWithTitle("Ok")
        alert.messageText = "Error Occurred"
        alert.informativeText = errorMessage
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.runModal()
        
    }
    
    //MARK: - Generating files content
    func generateClasses()
    {
        let str = sourceText.string! as NSString
        let rootClassName = classNameField.stringValue
        
        
        if let data = str.dataUsingEncoding(NSUTF8StringEncoding){
            var error : NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: .allZeros, error: &error) as? [String : AnyObject]{
                loadSelectedLanguageModel()
                addFileWithName(rootClassName, jsonObject:json)
               
            }else{
                if error != nil{
                    showError(error!)
                }else{
                    showError("Error while parsing the json")
                }
            }
        }
    }
    
    
    
    func addFileWithName(className: String, jsonObject: NSDictionary){
        var properties = [Property]()
        var jsonProperties = sorted(jsonObject.allKeys as [String])
        
        for jsonPropertyName in jsonProperties{
            
            let swiftPropertyName = propertySwiftName(jsonPropertyName)
            
            let value : AnyObject = jsonObject[jsonPropertyName]!
            
            var type = propertyTypeName(value)
            
            var isDictionary = false
            var isArray = false
            
            if value is NSDictionary{
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
        
        files.append(FileRepresenter(className: className, properties: properties, lang:selectedLang))
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
        var swiftClassName = underscoresToCamelCaseForString(propertyName, startFromFirstChar: true)
        
        return swiftClassName.toSingular()
    }
    
    func propertyTypeName(value : AnyObject) -> String
    {
        var name = ""
        if value is NSArray{
            name = typeNameForArrayElements(value as NSArray)
        }else if value is NSNumber{
            name = typeForNumber(value as NSNumber)
        }else if value is NSString{
            name = selectedLang.dataTypes.stringType
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
    
    
    
   

}

