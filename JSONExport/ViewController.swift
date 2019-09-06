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
    //Call only from main thread
    var selectedLanguageName : String
    {
        assert(Thread.isMainThread);
        return languagesPopup.titleOfSelectedItem!
    }
    
    //Should hold list of supported languages, where the key is the language name and the value is LangModel instance
    var langs : [String : LangModel] = [String : LangModel]()
    
    //Holds list of the generated files
    var files : [FileRepresenter] = [FileRepresenter]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        sourceText.isAutomaticQuoteSubstitutionEnabled = false
        loadSupportedLanguages()
        setupNumberedTextView()
        setLanguagesSelection()
        loadLastSelectedLanguage()
        updateUIFieldsForSelectedLanguage()
		self.tableView.backgroundColor = .clear
    }
    
    /**
     Sets the values of languagesPopup items' titles
     */
    func setLanguagesSelection()
    {
        let langNames = Array(langs.keys).sorted()
        languagesPopup.removeAllItems()
        languagesPopup.addItems(withTitles: langNames)
        
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
        sourceText.font = NSFont.userFixedPitchFont(ofSize: NSFont.smallSystemFontSize)
        
    }
    
    /**
     Updates the visible fields according to the selected language
     */
    func updateUIFieldsForSelectedLanguage()
    {
        loadSelectedLanguageModel()
        if selectedLang.supportsFirstLineStatement != nil && selectedLang.supportsFirstLineStatement!{
            firstLineField.isHidden = false
            firstLineField.placeholderString = selectedLang.firstLineHint
        }else{
            firstLineField.isHidden = true
        }
        
        if selectedLang.modelDefinitionWithParent != nil || selectedLang.headerFileData?.modelDefinitionWithParent != nil{
            parentClassName.isHidden = false
        }else{
            parentClassName.isHidden = true
        }
    }
    
    /**
     Loads last selected language by user
     */
    func loadLastSelectedLanguage()
    {
        guard let lastSelectedLanguage = UserDefaults.standard.value(forKey: "selectedLanguage") as? String else{
            return
        }
        
        if langs[lastSelectedLanguage] != nil{
            languagesPopup.selectItem(withTitle: lastSelectedLanguage)
        }
    }
    
    //MARK: - Handling pre defined languages
    func loadSupportedLanguages()
    {
		if let langFiles = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil){
            for langFile in langFiles{
                if let data = try? Data(contentsOf: langFile), let langDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? NSDictionary{
                    let lang = LangModel(fromDictionary: langDictionary)
                    if langs[lang.displayLangName] != nil{
                        continue
                    }
                    langs[lang.displayLangName] = lang
                }
            }
        }
    }

    
    // MARK: - parse the json file
    func parseJSONData(jsonData: Data!)
    {
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        sourceText.string = jsonString!
    }
    
    //MARK: - Handlind events
    
	@IBAction func openJSONFiles(sender: AnyObject)
	{
		let oPanel: NSOpenPanel = NSOpenPanel()
		oPanel.canChooseDirectories = false
		oPanel.canChooseFiles = true
		oPanel.allowsMultipleSelection = false
		oPanel.allowedFileTypes = ["json","JSON"]
		oPanel.prompt = "Choose JSON file"
		
		oPanel.beginSheetModal(for: self.view.window!) { button in
			if button.rawValue == NSFileHandlingPanelOKButton {
				let jsonPath = oPanel.urls.first!.path
				let fileHandle = FileHandle(forReadingAtPath: jsonPath)
				let urlStr:String  = oPanel.urls.first!.lastPathComponent
				self.classNameField.stringValue = urlStr.replacingOccurrences(of: ".json", with: "")
				self.parseJSONData(jsonData: (fileHandle!.readDataToEndOfFile()))
			}
		}
	}
    
    
    @IBAction func toggleConstructors(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func toggleUtilities(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    @IBAction func rootClassNameChanged(_ sender: AnyObject) {
        generateClasses()
    }
    
    @IBAction func parentClassNameChanged(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func classPrefixChanged(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    
    @IBAction func selectedLanguageChanged(_ sender: AnyObject)
    {
        updateUIFieldsForSelectedLanguage()
        generateClasses()
        DispatchQueue.main.async {
            UserDefaults.standard.set(self.selectedLanguageName, forKey: "selectedLanguage")
        }
        
    }
    
    
    @IBAction func firstLineChanged(_ sender: AnyObject)
    {
        generateClasses()
    }
    
    //MARK: - NSTextDelegate
    
    func textDidChange(_ notification: Notification) {
        generateClasses()
    }
    
    
    //MARK: - Language selection handling
    func loadSelectedLanguageModel()
    {
       selectedLang = langs[self.selectedLanguageName]
    }
    
    
    //MARK: - NSUserNotificationCenterDelegate
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool
    {
        return true
    }
    
    
    //MARK: - Showing the open panel and save files
    @IBAction func saveFiles(_ sender: AnyObject)
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsOtherFileTypes = false
        openPanel.treatsFilePackagesAsDirectories = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Choose"
		openPanel.beginSheetModal(for: self.view.window!){ button in
			if button.rawValue == NSFileHandlingPanelOKButton{
				self.saveToPath(openPanel.url!.path)
				self.showDoneSuccessfully()
			}
		}
    }
    
    
    /**
     Saves all the generated files in the specified path
     
     - parameter path: in which to save the files
     */
    func saveToPath(_ path : String)
    {
        var error : NSError?
        for file in files{
            var fileContent = file.fileContent
            if fileContent == ""{
                fileContent = file.toString()
            }
            var fileExtension = selectedLang.fileExtension
            if file is HeaderFileRepresenter{
                fileExtension = selectedLang.headerFileData.headerFileExtension
            }
            let filePath = "\(path)/\(file.className).\(fileExtension)"
            
            do {
                try fileContent.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
            } catch let error1 as NSError {
                error = error1
            }
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
        notification.deliveryDate = Date()
        
        let center = NSUserNotificationCenter.default
        center.delegate = self
        center.deliver(notification)
    }
    
    /**
     Shows an NSAlert for the passed error
     */
    func showError(_ error: NSError!)
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
    func showErrorStatus(_ errorMessage: String)
    {
        
        statusTextField.textColor = NSColor.red
        statusTextField.stringValue = errorMessage
    }
    
    /**
     Shows the passed success status message
     */
    func showSuccessStatus(_ successMessage: String)
    {
        
        statusTextField.textColor = NSColor.green
        statusTextField.stringValue = successMessage
    }
    
    
    
    //MARK: - Generate files content
    /**
     Validates the sourceText string input, and takes any needed action to generate the model classes and view them in the preview panel
     */
    func generateClasses()
    {
        saveButton.isEnabled = false
        var str = sourceText.string
        
        if str.count == 0{
            runOnUiThread{
                //Nothing to do, just clear any generated files
                self.files.removeAll(keepingCapacity: false)
                self.tableView.reloadData()
            }
            return;
        }
        var rootClassName = classNameField.stringValue
        if rootClassName.count == 0{
            rootClassName = "RootClass"
        }
        sourceText.isEditable = false
        //Do the lengthy process in background, it takes time with more complicated JSONs
        runOnBackground {
            str = stringByRemovingControlCharacters(str)
            if let data = str.data(using: String.Encoding.utf8){
                var error : NSError?
                do {
                    let jsonData : Any = try JSONSerialization.jsonObject(with: data, options: [])
                    var json : NSDictionary!
                    if jsonData is NSDictionary{
                        //fine nothing to do
						json = jsonData as? NSDictionary
                    }else{
                        json = unionDictionaryFromArrayElements(jsonData as! NSArray)
                    }
                    
                    runOnUiThread{
                        self.loadSelectedLanguageModel()
                        self.files.removeAll(keepingCapacity: false)
                        let fileGenerator = self.prepareAndGetFilesBuilder()
                        fileGenerator.addFileWithName(&rootClassName, jsonObject: json, files: &self.files)
                        fileGenerator.fixReferenceMismatches(inFiles: self.files)
                        self.files = Array(self.files.reversed())
                        self.sourceText.isEditable = true
                        self.showSuccessStatus("Valid JSON structure")
                        self.saveButton.isEnabled = true
                        
                        self.tableView.reloadData()
                        self.tableView.layout()
                    }
                } catch let error1 as NSError {
                    error = error1
                    runOnUiThread({ () -> Void in
                        self.sourceText.isEditable = true
                        self.saveButton.isEnabled = false
                        if error != nil{
                            print(error!)
                        }
                        self.showErrorStatus("It seems your JSON object is not valid!")
                    })
                    
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    /**
     Creates and returns an instance of FilesContentBuilder. It also configure the values from the UI components to the instance. I.e includeConstructors
     
     - returns: instance of configured FilesContentBuilder
     */
    func prepareAndGetFilesBuilder() -> FilesContentBuilder
    {
        let filesBuilder = FilesContentBuilder.instance
        filesBuilder.includeConstructors = (generateConstructors.state == NSControl.StateValue.on)
        filesBuilder.includeUtilities = (generateUtilityMethods.state == NSControl.StateValue.on)
        filesBuilder.firstLine = firstLineField.stringValue
        filesBuilder.lang = selectedLang!
        filesBuilder.classPrefix = classPrefixField.stringValue
        filesBuilder.parentClassName = parentClassName.stringValue
        return filesBuilder
    }
    
    
    
    
    //MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return files.count
    }
    
    
    //MARK: - NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("fileCell"), owner: self) as! FilePreviewCell
        let file = files[row]
        cell.file = file
        
        return cell
    }
    
    
    
}
