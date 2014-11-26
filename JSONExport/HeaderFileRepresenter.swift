//
//  HeaderFileRepresenter.swift
//  JSONExport
//  Created by Ahmed Ali on 11/23/14.
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

class HeaderFileRepresenter : FileRepresenter{
    /**
    Generates the header file content and stores it in the fileContent property
    */
    override func toString() -> String{
        fileContent = ""
        appendCopyrights()
        appendStaticImports()
        appendCustomImports()
        //start the model defination
        fileContent += lang.headerFileData.modelDefinition.stringByReplacingOccurrencesOfString(modelName, withString: className)
        //start the model content body
        fileContent += "\(lang.modelStart)"
        
        appendProperties()
        appendInitializers()
        appendUtilityMethods()
        fileContent += lang.modelEnd
        return fileContent
    }
    
  
    
    /**
    Appends the lang.headerFileData.staticImports if any
    */
    override func appendStaticImports()
    {
        if lang.headerFileData.staticImports != nil{
            fileContent += lang.headerFileData.staticImports
            fileContent += "\n"
        }
    }
    
    /**
    Tries to access the address book in order to fetch basic information about the author so it can include a nice copyright statment
    */
    override func appendCopyrights()
    {
        if let me = ABAddressBook.sharedAddressBook()?.me(){
            fileContent += "//\n//\t\(className).\(lang.headerFileData.headerFileExtension)\n"
            if let firstName = me.valueForProperty(kABFirstNameProperty as String)? as? String{
                fileContent += "//\n//\tCreate by \(firstName)"
                if let lastName = me.valueForProperty(kABLastNameProperty as String)? as? String{
                    fileContent += " \(lastName)"
                }
            }
            
            
            fileContent += " on \(getTodayFormattedDay())\n//\tCopyright © \(getYear())"
            
            if let organization = me.valueForProperty(kABOrganizationProperty as String)? as? String{
                fileContent += " \(organization)"
            }
            
            fileContent += ". All rights reserved.\n//\n\n"
            
        }
        
    }
    
    
    /**
    Loops on all properties which has a custom type and appends the custom import from the lang.headerFileData's importForEachCustomType property
    
    */
    override func appendCustomImports()
    {
        if lang.importForEachCustomType != nil{
            for property in properties{
                if property.isCustomClass{
                    fileContent += lang.headerFileData.importForEachCustomType.stringByReplacingOccurrencesOfString(modelName, withString: property.type)
                }else if property.isArray{
                    //if it is an array of custom types
                    let basicTypes = lang.dataTypes.toDictionary().allValues as [String]
                    if find(basicTypes, property.elementsType) == nil{
                        fileContent += lang.headerFileData.importForEachCustomType.stringByReplacingOccurrencesOfString(modelName, withString: property.elementsType)
                    }
                }
            }
        }
    }
    
    /**
    Appends all the properties using the Property.stringPresentation method
    */
    override func appendProperties()
    {
        fileContent += "\n"
        for property in properties{
            fileContent += property.toString(forHeaderFile: true)
        }
    }
    
    /**
    Appends all the defined constructors (aka initializers) in lang.constructors to the fileContent
    */
    override func appendInitializers()
    {
        if !includeConstructors{
            return
        }
        fileContent += "\n"
        for constructorSignature in lang.headerFileData.constructorSignatures{
           
            fileContent += constructorSignature
            
            fileContent = fileContent.stringByReplacingOccurrencesOfString(modelName, withString: className)
        }
    }
    
    
    /**
    Appends all the defined utility methods in lang.utilityMethods to the fileContent
    */
    override func appendUtilityMethods()
    {
        if !includeUtilities{
            return
        }
        fileContent += "\n"
        for methodSignature in lang.headerFileData.utilityMethodSignatures{
            fileContent += methodSignature
        }
    }
}