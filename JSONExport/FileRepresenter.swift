//
//  FileRepresenter.swift
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

import Foundation
import AddressBook

/**
FileRepresenter is used to generate a valid syntax for the target language that represents JSON object
*/
class FileRepresenter{
    /**
    Holds the class (or type) name
    */
    var className : String
    
    /**
    Array of properties which will be included in the file content
    */
    var properties : [Property]
    
    /**
    The target language meta instance
    */
    var lang : LangModel
    
    /**
    Whether to include constructors (aka initializers in Swift) in the file content
    */
    var includeConstructors = true
    
    /**
    Whether to include utility methods in the file content. Utility methods such as toDictionary method
    */
    var includeUtilities = true
    
    /**
    If the target language supports first line statement (i.e package names in Java), then you can set the value of this property to whatever the first line statement is.
    */
    var firstLine = ""
    
    /**
    If the target language supports inheritance, all the generated classes will be subclasses of this class
    */
    var parentClassName = ""
    
    /**
    After the first time you use the toString() method, this property will contain the file content.
    */
    var fileContent = ""
    
  
    /**
    Designated initializer
    */
    init(className: String, properties: [Property], lang: LangModel)
    {
        self.className = className
        self.properties = properties
        self.lang = lang
    }
    
    /**
    Generates the file content and stores it in the fileContent property
    */
    func toString() -> String{
        fileContent = ""
        appendFirstLineStatement()
        appendCopyrights()
        appendStaticImports()
        appendHeaderFileImport()
        appendCustomImports()
        //start the model defination
        var definition = ""
        if lang.modelDefinitionWithParent != nil && count(parentClassName) > 0{
            definition = lang.modelDefinitionWithParent.stringByReplacingOccurrencesOfString(modelName, withString: className)
            definition = definition.stringByReplacingOccurrencesOfString(modelWithParentClassName, withString: parentClassName)
        }else if includeUtilities && lang.defaultParentWithUtilityMethods != nil{
            definition = lang.modelDefinitionWithParent.stringByReplacingOccurrencesOfString(modelName, withString: className)
            definition = definition.stringByReplacingOccurrencesOfString(modelWithParentClassName, withString: lang.defaultParentWithUtilityMethods)
        }else{
            definition = lang.modelDefinition.stringByReplacingOccurrencesOfString(modelName, withString: className)
        }
        fileContent += definition
        //start the model content body
        fileContent += "\(lang.modelStart)"
        
        appendProperties()
        appendSettersAndGetters()
        appendInitializers()
        appendUtilityMethods()
        fileContent = fileContent.stringByReplacingOccurrencesOfString(lowerCaseModelName, withString:className.lowercaseFirstChar())
        fileContent = fileContent.stringByReplacingOccurrencesOfString(modelName, withString:className)
        fileContent += lang.modelEnd
        return fileContent
    }
    
    /**
    Appneds the firstLine value (if any) to the fileContent if the lang.supportsFirstLineStatement is true
    */
    func appendFirstLineStatement()
    {
        if lang.supportsFirstLineStatement != nil && lang.supportsFirstLineStatement! && count(firstLine) > 0{
            fileContent += "\(firstLine)\n\n"
        }
    }
    
    /** 
    Appends the lang.staticImports if any
    */
    func appendStaticImports()
    {
        if lang.staticImports != nil{
            fileContent += lang.staticImports
            fileContent += "\n"
        }
    }

    func appendHeaderFileImport()
    {
        if lang.importHeaderFile != nil{
            fileContent += "\n"
            fileContent += lang.importHeaderFile
            fileContent = fileContent.stringByReplacingOccurrencesOfString(modelName, withString: className)
        }
    }
    
    /**
    Tries to access the address book in order to fetch basic information about the author so it can include a nice copyright statment
    */
    func appendCopyrights()
    {
        fileContent += "//\n//\t\(className).\(lang.fileExtension)\n"
        if let me = ABAddressBook.sharedAddressBook()?.me(){
            
            if let firstName = me.valueForProperty(kABFirstNameProperty as String) as? String{
                fileContent += "//\n//\tCreate by \(firstName)"
                if let lastName = me.valueForProperty(kABLastNameProperty as String) as? String{
                   fileContent += " \(lastName)"
                }
            }
            
            
            fileContent += " on \(getTodayFormattedDay())\n//\tCopyright © \(getYear())"
            
            if let organization = me.valueForProperty(kABOrganizationProperty as String) as? String{
                fileContent += " \(organization)"
            }
            
            fileContent += ". All rights reserved.\n"
        }
        
        fileContent += "//\tModel file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport\n\n"
        
    }
    
    /**
    Returns the current year as String
    */
    func getYear() -> String
    {
        return "\(NSCalendar.currentCalendar().component(.CalendarUnitYear, fromDate: NSDate()))"
    }
    
    /**
    Returns today date in the format dd/mm/yyyy
    */
    func getTodayFormattedDay() -> String
    {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate())
        return "\(components.day)/\(components.month)/\(components.year)"
    }

    /**
     Loops on all properties which has a custom type and appends the custom import from the lang's importForEachCustomType property

    */
    func appendCustomImports()
    {
        if lang.importForEachCustomType != nil{
            for property in properties{
                if property.isCustomClass{
                    fileContent += lang.importForEachCustomType.stringByReplacingOccurrencesOfString(modelName, withString: property.type)
                }else if property.isArray && property.elementsAreOfCustomType{
                    fileContent += lang.importForEachCustomType.stringByReplacingOccurrencesOfString(modelName, withString: property.elementsType)
                }
            }
        }
    }
    
    /**
    Appends all the properties using the Property.toString(forHeaderFile: false) method
    */
    func appendProperties()
    {
        fileContent += "\n"
        for property in properties{
            
            fileContent += property.toString(forHeaderFile: false)
        }
    }
    
    /**
    Appends the setter and getter for each property if the current target language supports them (i.e the convension in Java is to use private instance variables with public setters and getters). The method will use special getter for boolean properties if required by the target language
    */
    func appendSettersAndGetters()
    {
        fileContent += "\n"
        for property in properties{
            //append the setter
            let capVarName = property.nativeName.uppercaseFirstChar()
            if lang.setter != nil{
                var set = lang.setter
                
                set = set.stringByReplacingOccurrencesOfString(capitalizedVarName, withString: capVarName)
                set = set.stringByReplacingOccurrencesOfString(varName, withString: property.nativeName)
                set = set.stringByReplacingOccurrencesOfString(varType, withString: property.type)
                fileContent += set
            }
            
            // append the getters
            var get : String!
            //if the property is a boolean property determine if there is a special getter for boolean properties
            if property.type == lang.dataTypes.boolType{
                if lang.booleanGetter != nil{
                    get = lang.booleanGetter
                    
                }else{
                    //use normal getter
                    get = lang.getter
                }
            }else{
                get = lang.getter
            }
            
            if get != nil{
                get = get.stringByReplacingOccurrencesOfString(capitalizedVarName, withString: capVarName)
                get = get.stringByReplacingOccurrencesOfString(varName, withString: property.nativeName)
                get = get.stringByReplacingOccurrencesOfString(varType, withString: property.type)
                fileContent += get
            }
            
        }
    }
    
    /**
    Appends all the defined constructors (aka initializers) in lang.constructors to the fileContent
    */
    func appendInitializers()
    {
        if !includeConstructors{
            return
        }
        fileContent += "\n"
        for constructor in lang.constructors{
            if constructor.comment != nil{
                fileContent += constructor.comment
            }
            
            fileContent += constructor.signature
            fileContent += constructor.bodyStart
            
            for property in properties{
                
                fileContent += propertyFetchFromJsonSyntaxForProperty(property, constructor: constructor)
            }
            
            fileContent += constructor.bodyEnd
            fileContent = fileContent.stringByReplacingOccurrencesOfString(modelName, withString: className)
        }
    }
    
    
    /**
    Appends all the defined utility methods in lang.utilityMethods to the fileContent
    */
    func appendUtilityMethods()
    {
        if !includeUtilities{
            return
        }
        fileContent += "\n"
        for method in lang.utilityMethods{
            if method.comment != nil{
                fileContent += method.comment
            }
            fileContent += method.signature
            fileContent += method.bodyStart
            fileContent += method.body
            for property in properties{
                var propertyHandlingStr = ""
                if property.isArray{
                    if propertyTypeIsBasicType(property){
                        propertyHandlingStr = method.forEachProperty
                        
                    }else{
                        propertyHandlingStr = method.forEachArrayOfCustomTypeProperty
                    }
                    propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(elementType, withString: property.elementsType)
                }else{
                    if lang.basicTypesWithSpecialStoringNeeds != nil && method.forEachPropertyWithSpecialStoringNeeds != nil && find(lang.basicTypesWithSpecialStoringNeeds, property.type) != nil{
                        propertyHandlingStr = method.forEachPropertyWithSpecialStoringNeeds
                    }else{
                        propertyHandlingStr = method.forEachProperty
                        if property.isCustomClass{
                            propertyHandlingStr = method.forEachCustomTypeProperty
                        }
                    }
                    
                }
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(varName, withString:property.nativeName)
                
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(varType, withString:property.type)
                
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(jsonKeyName, withString:property.jsonName)
                
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(additionalCustomTypeProperty, withString:"")
                if lang.basicTypesWithSpecialFetchingNeeds != nil{
                    if let index = find(lang.basicTypesWithSpecialFetchingNeeds, property.type), let replacement = lang.basicTypesWithSpecialFetchingNeedsReplacements?[index]{
                       propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(varTypeReplacement, withString: replacement)
                        
                        
                        let lowerCaseType = property.type.lowercaseString
                        propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(lowerCaseVarType, withString: lowerCaseType)
                        
                    }
                }
                fileContent += propertyHandlingStr
            }
            fileContent += method.returnStatement
            fileContent += method.bodyEnd
        }
        
        
    }
    
    /**
    Returns true if the passed property.type is one of the basic types or an array of any of the basic types, otherwise returns false
    */
    func propertyTypeIsBasicType(property: Property) -> Bool{
        var isBasicType = false
        var type = propertyTypeWithoutArrayWords(property)
        if lang.genericType == type{
            isBasicType = true
        }else{
            let basicTypes = lang.dataTypes.toDictionary().allValues as! [String]
            
            if find(basicTypes, type) != nil{
                isBasicType = true
            }
        }
        
        
        return isBasicType
    }
    
    /**
    Removes any "array-specific character or words" from the passed type to return the type of the array elements. The "array-specific character or words" are fetched from the lang.wordsToRemoveToGetArrayElementsType property
    */
    func propertyTypeWithoutArrayWords(property: Property) -> String
    {
        
        var type = property.type
        
        for arrayWord in lang.wordsToRemoveToGetArrayElementsType{
            type = type.stringByReplacingOccurrencesOfString(arrayWord, withString: "")
        }
        
        if count(type) == 0{
            type = typeNameForArrayElements(property.sampleValue as! NSArray, lang: lang)
        }
        return type
    }
    
    //MARK: - Fetching property from a JSON object
    /**
    Returns the suitable syntax to fetch the value of the property from a JSON object for the passed constructor
    */
    func propertyFetchFromJsonSyntaxForProperty(property: Property, constructor: Constructor) -> String
    {
        var propertyStr = ""
        if property.isCustomClass{
            
            propertyStr = constructor.fetchCustomTypePropertyFromMap
            
        }else if property.isArray{
            propertyStr = fetchArrayFromJsonSyntaxForProperty(property, constructor: constructor)
            
        }else {
            propertyStr = fetchBasicTypePropertyFromJsonSyntaxForProperty(property, constructor: constructor)
            
        }
        //Apply all the basic replacements
        propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varName, withString: property.nativeName)
        propertyStr = propertyStr.stringByReplacingOccurrencesOfString(jsonKeyName, withString: property.jsonName)
        propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varType, withString: property.type)
        let capVarName = property.nativeName.capitalizedString
        let capVarType = property.type.capitalizedString;
        propertyStr = propertyStr.stringByReplacingOccurrencesOfString(capitalizedVarName, withString: capVarName)
        propertyStr = propertyStr.stringByReplacingOccurrencesOfString(capitalizedVarType, withString: capVarType)
        return propertyStr
    }
    
    /**
    Returns valid syntax to fetch an array from a JSON object
    */
    func fetchArrayFromJsonSyntaxForProperty(property: Property, constructor: Constructor) -> String
    {
        var propertyStr = ""
        if(propertyTypeIsBasicType(property)){
            
            if constructor.fetchArrayOfBasicTypePropertyFromMap != nil{
                if let index = find(lang.basicTypesWithSpecialFetchingNeeds, property.elementsType){
                    propertyStr = constructor.fetchArrayOfBasicTypePropertyFromMap
                    let replacement = lang.basicTypesWithSpecialFetchingNeedsReplacements[index]
                    propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varTypeReplacement, withString: replacement)
                }else{
                    propertyStr = constructor.fetchBasicTypePropertyFromMap
                }
            }else{
                propertyStr = constructor.fetchBasicTypePropertyFromMap
            }
            
        }else{
            //array of custom type
            propertyStr = constructor.fetchArrayOfCustomTypePropertyFromMap
            
           
            
        }
         propertyStr = propertyStr.stringByReplacingOccurrencesOfString(elementType, withString: property.elementsType)
        return propertyStr
    }
    
    /**
    Returns valid syntax to fetch any property with basic type from a JSON object
    */
    func fetchBasicTypePropertyFromJsonSyntaxForProperty(property: Property, constructor: Constructor) -> String
    {
        var propertyStr = ""
        if lang.basicTypesWithSpecialFetchingNeeds != nil{
            let index = find(lang.basicTypesWithSpecialFetchingNeeds, property.type)
            if index != nil{
                propertyStr = constructor.fetchBasicTypeWithSpecialNeedsPropertyFromMap
                if let replacement = lang.basicTypesWithSpecialFetchingNeedsReplacements?[index!]{
                    propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varTypeReplacement, withString: replacement)
                }
                
                let lowerCaseType = property.type.lowercaseString
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(lowerCaseVarType, withString: lowerCaseType)
                
            }else{
                propertyStr = constructor.fetchBasicTypePropertyFromMap
            }
            
        }else{
            propertyStr = constructor.fetchBasicTypePropertyFromMap
        }
        
        return propertyStr
    }
}