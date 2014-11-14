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

class FileRepresenter{
    var className : String
    var properties : [Property]
    var lang : LangModel
    var stringContent = ""
    var includeConstructors = true
    var includeUtilities = true
    
    init(className: String, properties: [Property], lang: LangModel)
    {
        self.className = className
        self.properties = properties
        self.lang = lang
    }
    
    func toString() -> String{
        stringContent = ""
        appendCopyrights()
        
        if lang.staticImports != nil{
            stringContent += lang.staticImports
            stringContent += "\n"
        }
        appendCustomImports()
        stringContent += lang.modelDefinition.stringByReplacingOccurrencesOfString(modelName, withString: className)
        
        stringContent += "\(lang.modelStart)"
        
        
        appendProperties()
        appendSettersAndGetters()
        if includeConstructors{
            appendInitializers()
        }
        if includeUtilities{
            appendUtilityMethods()
        }
        stringContent += lang.modelEnd
        return stringContent
    }
    
    func appendCopyrights()
    {
        let book = ABAddressBook.sharedAddressBook()
        let me : ABPerson = book.me()
        stringContent += "//\n//\t\(className).\(lang.fileExtension)\n"
        stringContent += "//\n//\tCreate by "
        stringContent += me.valueForProperty(kABFirstNameProperty as String) as String
        stringContent += " "
        stringContent += me.valueForProperty(kABLastNameProperty as String) as String
        stringContent += " on \(getTodayFormattedDay())\n//\tCopyright (c) \(getYear()) "
        stringContent += me.valueForProperty(kABOrganizationProperty as String) as String
        stringContent += ". All rights reserved.\n//\n\n"
    }
    
    func getYear() -> String
    {
        return "\(NSCalendar.currentCalendar().component(.CalendarUnitYear, fromDate: NSDate()))"
    }
    
    func getTodayFormattedDay() -> String
    {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate())
        return "\(components.day)/\(components.month)/\(components.year)"
    }

    
    func appendCustomImports()
    {
        if lang.importForEachCustomType != nil{
            for property in properties{
                if property.isCustomClass{
                    stringContent += lang.importForEachCustomType.stringByReplacingOccurrencesOfString(modelName, withString: property.type)
                }
            }
        }
    }
    
    func appendProperties()
    {
        stringContent += "\n"
        for property in properties{
            stringContent += property.stringPresentation()
        }
    }
    
    func appendSettersAndGetters()
    {
        stringContent += "\n"
        for property in properties{
            let capVarName = property.nativeName.capitalizedString
            if lang.setter != nil{
                var set = lang.setter
                
                set = set.stringByReplacingOccurrencesOfString(capitalizedVarName, withString: capVarName)
                set = set.stringByReplacingOccurrencesOfString(varName, withString: property.nativeName)
                set = set.stringByReplacingOccurrencesOfString(varType, withString: property.type)
                stringContent += set
            }
            
            var get : String!
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
                stringContent += get
            }
        }
    }
    
    func appendInitializers()
    {
        stringContent += "\n"
        for constructor in lang.constructors{
            if constructor.comment != nil{
                stringContent += constructor.comment
            }
            
            stringContent += constructor.signature
            stringContent += constructor.bodyStart
            for property in properties{
                var propertyStr = ""
                if property.isCustomClass{
                    
                    propertyStr = constructor.fetchCustomTypePropertyFromMap
                    
                }else if property.isArray{
                    if(propertyTypeIsBasicType(property)){
                        propertyStr = constructor.fetchBasicTypePropertyFromMap
                    }else{
                        //array of custom type
                        propertyStr = constructor.fetchArrayOfCustomTypePropertyFromMap
                        let perpertyElementType = elementTypeNameFromArrayProperty(property.type)
                        propertyStr = propertyStr.stringByReplacingOccurrencesOfString(elementType, withString: perpertyElementType)
                        
                        
                    }
                }else {
                    if lang.basicTypesWithSpecialFetchingNeeds != nil && find(lang.basicTypesWithSpecialFetchingNeeds, property.type) != nil{
                        
                        propertyStr = constructor.fetchBasicTypeWithSpecialNeedsPropertyFromMap
                        let lowerCaseType = property.type.lowercaseString
                        propertyStr = propertyStr.stringByReplacingOccurrencesOfString(lowerCaseVarType, withString: lowerCaseType)
                        
                    }else{
                        propertyStr = constructor.fetchBasicTypePropertyFromMap
                    }
                    
                    
                }
                
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varName, withString: property.nativeName)
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(jsonKeyName, withString: property.jsonName)
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varType, withString: property.type)
                let capVarName = property.nativeName.capitalizedString
                let capVarType = property.type.capitalizedString;
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(capitalizedVarName, withString: capVarName)
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(capitalizedVarType, withString: capVarType)
                stringContent += propertyStr
            }
            
            stringContent += constructor.bodyEnd
            stringContent = stringContent.stringByReplacingOccurrencesOfString(modelName, withString: className)
        }
    }
    
    func appendUtilityMethods()
    {
        stringContent += "\n"
        for method in lang.utilityMethods{
            if method.comment != nil{
                stringContent += method.comment
            }
            stringContent += method.signature
            stringContent += method.bodyStart
            stringContent += method.body
            for property in properties{
                var propertyHandlingStr = ""
                if property.isArray{
                    if propertyTypeIsBasicType(property){
                        propertyHandlingStr = method.forEachProperty
                        
                    }else{
                        propertyHandlingStr = method.forEachArrayOfCustomTypeProperty
                    }
                }else{
                    propertyHandlingStr = method.forEachProperty
                    if property.isCustomClass{
                        propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(additionalCustomTypeProperty, withString:method.additionalyForEachCustomTypeProperty)
                    }
                }
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(varName, withString:property.nativeName)
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(varType, withString:property.type)
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(jsonKeyName, withString:property.jsonName)
                propertyHandlingStr = propertyHandlingStr.stringByReplacingOccurrencesOfString(additionalCustomTypeProperty, withString:"")
                stringContent += propertyHandlingStr
            }
            stringContent += method.returnStatement
            stringContent += method.bodyEnd
        }
        
        
    }
    
    
    func propertyTypeIsBasicType(property: Property) -> Bool{
        var isBasicType = false
        var type = elementTypeNameFromArrayProperty(property.type)

        let basicTypes = lang.dataTypes.toDictionary().allValues as [String]
            if find(basicTypes, type) != nil{
                isBasicType = true
            }
        
        
        
        return isBasicType
    }
    
    func elementTypeNameFromArrayProperty(arrayTypeName : String) -> String
    {
        
        var type = arrayTypeName
        
        for arrayWord in lang.wordsToRemoveToGetArrayElementsType{
            type = type.stringByReplacingOccurrencesOfString(arrayWord, withString: "")
        }
        return type
    }
    
}


