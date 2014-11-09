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


class FileRepresenter{
    var className : String
    var properties : [Property]
    var lang : LangModel
    var str = ""
    
    
    init(className: String, properties: [Property], lang: LangModel)
    {
        self.className = className
        self.properties = properties
        self.lang = lang
    }
    
    func toString(#includeConstructors: Bool, includeUtilities: Bool) -> String{
        if lang.staticImports != nil{
            str += lang.staticImports
            str += "\n\n"
        }
        str += lang.modelDefinition.stringByReplacingOccurrencesOfString(modelName, withString: className)
        
        str += "\(lang.modelStart)\n"
        
        appendCustomImports()
        appendProperties()
        appendSettersAndGetters()
        if includeConstructors{
            appendInitializers()
        }
        if includeUtilities{
            appendUtilityMethods()
        }
        
        
        
        str += lang.modelEnd
        return str
    }
    
   
    func appendCustomImports()
    {
        if lang.importForEachCustomType != nil{
            for property in properties{
                if property.isCustomClass{
                    str += lang.importForEachCustomType.stringByReplacingOccurrencesOfString(modelName, withString: property.type)
                }
            }
        }
    }
    
    func appendProperties()
    {
        str += "\n"
        for property in properties{
            str += property.stringPresentation()
        }
    }
    
    func appendSettersAndGetters()
    {
        str += "\n"
        for property in properties{
            let capVarName = property.nativeName.capitalizedString
            if lang.setter != nil{
                var set = lang.setter
                
                set = set.stringByReplacingOccurrencesOfString(capitalizedVarName, withString: capVarName)
                set = set.stringByReplacingOccurrencesOfString(varName, withString: property.nativeName)
                set = set.stringByReplacingOccurrencesOfString(varType, withString: property.type)
                str += set
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
                str += get
            }
        }
    }
    
    func appendInitializers()
    {
        str += "\n"
        for constructor in lang.constructors{
            if constructor.comment != nil{
                str += constructor.comment
            }
            
            str += constructor.signature
            str += constructor.bodyStart
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
                    propertyStr = constructor.fetchBasicTypePropertyFromMap
                    
                }
                
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varName, withString: property.nativeName)
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(jsonKeyName, withString: property.jsonName)
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(varType, withString: property.type)
                let capVarName = property.nativeName.capitalizedString
                propertyStr = propertyStr.stringByReplacingOccurrencesOfString(capitalizedVarName, withString: capVarName)
                
                str += propertyStr
            }
            
            str += constructor.bodyEnd
        }
    }
    
    func appendUtilityMethods()
    {
        str += "\n"
        for method in lang.utilityMethods{
            if method.comment != nil{
                str += method.comment
            }
            str += method.signature
            str += method.bodyStart
            str += method.body
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
                str += propertyHandlingStr
            }
            str += method.returnStatement
            str += method.bodyEnd
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


