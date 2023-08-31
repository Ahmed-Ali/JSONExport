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

class HeaderFileRepresenter: FileRepresenter {
    /**
    Generates the header file content and stores it in the fileContent property
    */
    override func toString() -> String {
        fileContent = ""
        appendCopyrights()
        appendStaticImports()
        appendImportParentHeader()
        appendCustomImports()

        //start the model defination
        var definition = ""
        if lang.headerFileData.modelDefinitionWithParent != nil && parentClassName.count > 0 {
            definition = lang.headerFileData.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: parentClassName)
        } else if includeUtilities && lang.defaultParentWithUtilityMethods != nil {
            definition = lang.headerFileData.modelDefinitionWithParent.replacingOccurrences(of: modelName, with: className)
            definition = definition.replacingOccurrences(of: modelWithParentClassName, with: lang.headerFileData.defaultParentWithUtilityMethods)
        } else {
            definition = lang.headerFileData.modelDefinition.replacingOccurrences(of: modelName, with: className)
        }

        fileContent += definition
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
    override func appendStaticImports() {
        if lang.headerFileData.staticImports != nil {
            fileContent += lang.headerFileData.staticImports
            fileContent += "\n"
        }
    }

    func appendImportParentHeader() {
        if lang.headerFileData.importParentHeaderFile != nil && parentClassName.count > 0 {
            fileContent += lang.headerFileData.importParentHeaderFile.replacingOccurrences(of: modelWithParentClassName, with: parentClassName)
        }
    }

    /**
    Tries to access the address book in order to fetch basic information about the author so it can include a nice copyright statment
    */
    override func appendCopyrights() {
        if let me = ABAddressBook.shared()?.me() {
            fileContent += "//\n//\t\(self.className).\(lang.headerFileData.headerFileExtension!)\n"
            if let firstName = me.value(forProperty: kABFirstNameProperty as String) as? String {
                fileContent += "//\n//\tCreate by \(firstName)"
                if let lastName = me.value(forProperty: kABLastNameProperty as String) as? String {
                    fileContent += " \(lastName)"
                }
            }

            fileContent += " on \(getTodayFormattedDay())\n//\tCopyright © \(getYear())"

            if let organization = me.value(forProperty: kABOrganizationProperty as String) as? String {
                fileContent += " \(organization)"
            }

            fileContent += ". All rights reserved.\n//\n\n"
            //fileContent += "//\tModel file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport\n\n"
        }

    }

    /**
    Loops on all properties which has a custom type and appends the custom import from the lang.headerFileData's importForEachCustomType property
    
    */
    override func appendCustomImports() {
        if lang.importForEachCustomType != nil {
            for property in properties {
                if property.isCustomClass {
                    fileContent += lang.headerFileData.importForEachCustomType.replacingOccurrences(of: modelName, with: property.type)
                } else if property.isArray {
                    //if it is an array of custom types
                    if(property.elementsType != lang.genericType) {
                        let basicTypes = lang.dataTypes.toDictionary().allValues as! [String]
                        if basicTypes.index(of: property.elementsType) == nil {
                            fileContent += lang.headerFileData.importForEachCustomType.replacingOccurrences(of: modelName, with: property.elementsType)
                        }
                    }

                }
            }
        }
    }

    /**
    Appends all the properties using the Property.stringPresentation method
    */
    override func appendProperties() {
        fileContent += "\n"
        for property in properties {
            fileContent += property.toString(true)
        }
    }

    /**
    Appends all the defined constructors (aka initializers) in lang.constructors to the fileContent
    */
    override func appendInitializers() {
        if !includeConstructors {
            return
        }
        fileContent += "\n"
        for constructorSignature in lang.headerFileData.constructorSignatures {

            fileContent += constructorSignature

            fileContent = fileContent.replacingOccurrences(of: modelName, with: className)
        }
    }

    /**
    Appends all the defined utility methods in lang.utilityMethods to the fileContent
    */
    override func appendUtilityMethods() {
        if !includeUtilities {
            return
        }
        fileContent += "\n"
        for methodSignature in lang.headerFileData.utilityMethodSignatures {
            fileContent += methodSignature
        }
    }
}
