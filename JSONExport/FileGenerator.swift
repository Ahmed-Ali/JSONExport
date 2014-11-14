//
//  FileGenerator.swift
//  JSONExport
//
//  Created by Ahmed on 11/14/14.
//  Copyright (c) 2014 Ahmed Ali. All rights reserved.
//

import Foundation


class FileGenerator{
    
    var classPrefix = ""
    var lang : LangModel!
    var includeUtilities = true
    var includeConstructs = true
    var firstLine = ""
    
    class var instance : FileGenerator {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FileGenerator? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = FileGenerator()
        }
        return Static.instance!
    }
    
    func addFileWithName(var className: String, jsonObject: NSDictionary, inout files : [FileRepresenter]){
        var properties = [Property]()
        if !className.hasPrefix(classPrefix){
            className = "\(classPrefix)\(className)"
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
                addFileWithName(leafClassName, jsonObject: value as NSDictionary, files:&files)
                type = leafClassName
                properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, isArray: false, isCustomClass: true, lang:lang))
            }else if value is NSArray{
                //we need to check its elements...
                let array = value as NSArray
                if let dic = array.firstObject? as? NSDictionary{
                    //wow complicated
                    let leafClassName = classNameForPropertyName(jsonPropertyName)
                    addFileWithName(leafClassName, jsonObject: dic, files:&files)
                    type = lang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: leafClassName)
                    
                    properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, isArray: true, isCustomClass: false, lang:lang))
                }else{
                    properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, isArray: true, isCustomClass: false, lang:lang))
                }
            }else{
                properties.append(Property(jsonName: jsonPropertyName, nativeName: swiftPropertyName, type: type, lang:lang))
            }
            
            
        }
        
        
        let file = FileRepresenter(className: className, properties: properties, lang:lang)
        file.includeUtilities = includeUtilities
        file.includeConstructors = includeConstructs
        if lang.supportsFirstLineStatement != nil && lang.supportsFirstLineStatement!{
            file.firstLine = firstLine
        }else{
            file.firstLine = ""
        }
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
       
        if !swiftClassName.hasPrefix(classPrefix){
            swiftClassName = "\(classPrefix)\(swiftClassName)"
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
                name = lang.dataTypes.boolType
            }else{
                name = lang.dataTypes.stringType
            }
            
        }
        
        return name
    }
    
    
    func typeNameForArrayElements(elements: NSArray) -> String{
        var typeName : String!
        let genericType = lang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: lang.genericType)
        if elements.count == 0{
            typeName = genericType
            
        }
        for element in elements{
            let currElementTypeName = propertyTypeName(element)
            
            let arrayTypeName = lang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: currElementTypeName)
            
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
                typeName = lang.dataTypes.boolType
            }else{
                typeName = lang.dataTypes.characterType
            }
        case .ShortType, .IntType:
            typeName = lang.dataTypes.intType
        case .FloatType:
            typeName = lang.dataTypes.floatType
        case .DoubleType:
            typeName = lang.dataTypes.doubleType
        case .LongType, .LongLongType:
            typeName = lang.dataTypes.longType
        default:
            typeName = lang.dataTypes.intType
        }
        
        return typeName
    }
}