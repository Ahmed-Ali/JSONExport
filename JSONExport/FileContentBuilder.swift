//
//  FileGenerator.swift
//  JSONExport
//
//  Created by Ahmed on 11/14/14.
//  Copyright (c) 2014 Ahmed Ali. All rights reserved.
//

import Foundation

/**
Singleton used to build the file content with the current configurations
*/
class FilesContentBuilder{
    /**
    The prefix used for first level type names (and file names as well)
    */
    var classPrefix = ""
    
    /**
    The language for which the files' content should be created
    */
    var lang : LangModel!
    
    /**
    Whether to include utility methods in the generated content
    */
    var includeUtilities = true
    
    /**
    Whether to include constructors (aka initializers)
    */
    var includeConstructs = true
    
    /**
    Whatever value will be assinged to the firstLine property, will appear as the first line in every file if the target language supports first line statement
    */
    var firstLine = ""
    
    /**
    Lazely load and return the singlton instance of the FilesContentBuilder
    */
    class var instance : FilesContentBuilder {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FilesContentBuilder? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = FilesContentBuilder()
        }
        return Static.instance!
    }
    
    /**
    Generates a file using the passed className and jsonObject example and appends it in the passed files array
    */
    func addFileWithName(var className: String, jsonObject: NSDictionary, inout files : [FileRepresenter]){
        var properties = [Property]()
        if !className.hasPrefix(classPrefix){
            className = "\(classPrefix)\(className)"
        }
        //sort all the keys in the passed json dictionary
        var jsonProperties = sorted(jsonObject.allKeys as [String])
        
        //loop all the json properties and handle each one individually
        for jsonPropertyName in jsonProperties{
            let value : AnyObject = jsonObject[jsonPropertyName]!
            let property = propertyForValue(value, jsonKeyName: jsonPropertyName)
            
            //recursively handle custom types
            if property.isCustomClass{
                addFileWithName(property.type, jsonObject: value as NSDictionary, files:&files)
            }else if property.isArray{
                let array = value as NSArray
                if let dictionary = array.firstObject? as? NSDictionary{
                    let type = classNameForPropertyName(property.jsonName)
                    addFileWithName(type, jsonObject: dictionary, files:&files)
                }
            }
            
            properties.append(property)
            
        }
        
        //create the file
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
    
    
    /**
    Creates and returns a Property object passed on the passed value and json key name
    */
    func propertyForValue(value: AnyObject, jsonKeyName: String) -> Property
    {
        let nativePropertyName = propertyNativeName(jsonKeyName)
        var type = propertyTypeName(value)
        var isDictionary = false
        var isArray = false
        
        var property: Property!
        if value is NSDictionary {
            type = classNameForPropertyName(jsonKeyName)
            property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, isArray:false, isCustomClass: true, lang: lang)
            
        }else if value is NSArray{
            //we need to check its elements...
            let array = value as NSArray
            if let dic = array.firstObject? as? NSDictionary{
                //wow complicated
                let leafClassName = classNameForPropertyName(jsonKeyName)

                type = lang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: leafClassName)
                
                property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, isArray: true, isCustomClass: false, lang:lang)
            }else{
                property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, isArray: true, isCustomClass: false, lang:lang)
            }
        }else{
            property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, lang:lang)
        }
        
        return property
    }
    

    
    
    /**
    Returns a camel case presentation from the passed json key
    */
    func propertyNativeName(jsonName : String) -> String
    {
        return underscoresToCamelCaseForString(jsonName, startFromFirstChar: false)
    }
    
    /**
    Returns the input string with white spaces removed, and underscors converted to camel case
    :param: the input string
    :param: whether to start with upper case letter
    :return: the camel case version of the input
    */
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
    
    
    /**
    Creats and returns the class name for the passed proeprty name
    */
    func classNameForPropertyName(propertyName : String) -> String{
        var swiftClassName = underscoresToCamelCaseForString(propertyName, startFromFirstChar: true).toSingular()
       
        if !swiftClassName.hasPrefix(classPrefix){
            swiftClassName = "\(classPrefix)\(swiftClassName)"
        }
        return swiftClassName
    }
    
    /**
    Creats and returns the type name for the passed value
    */
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
    
    /**
    Tries to figur out the type of the elements of the passed array and returns the type of the array that can hold these values
    */
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
    
    /**
    Returns one of the possible types for any numeric value (int, float, double, etc...)
    */
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