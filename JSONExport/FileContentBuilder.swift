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
    var includeConstructors = true
    
    /**
    Whatever value will be assinged to the firstLine property, will appear as the first line in every file if the target language supports first line statement
    */
    var firstLine = ""
    
    /**
    If the target language supports inheritance, all the generated classes will be subclasses of this class
    */
    var parentClassName = ""
    
    /**
    Lazely load and return the singleton instance of the FilesContentBuilder
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
    
    :param: className for the file to be generated, if the file already exist with different name, this className will be changed
    :param: jsonObject acts as an example of the json object, which the generated fill be able to handle
    :param: files the generated file will be appended to this array
    */
    func addFileWithName(inout className: String, jsonObject: NSDictionary, inout files : [FileRepresenter],toOneRelationWithProperty: Property! = nil)
    {
        var properties = [Property]()
        if !className.hasPrefix(classPrefix){
            className = "\(classPrefix)\(className)"
        }
        if toOneRelationWithProperty != nil{
            if lang.supportMutualRelationships != nil && lang.supportMutualRelationships!{
                properties.append(toOneRelationWithProperty)
            }
            
        }
        //sort all the keys in the passed json dictionary
        var jsonProperties = sorted(jsonObject.allKeys as [String])
        
        //loop all the json properties and handle each one individually
        for jsonPropertyName in jsonProperties{
            let value : AnyObject = jsonObject[jsonPropertyName]!
            let property = propertyForValue(value, jsonKeyName: jsonPropertyName)
            
            //recursively handle custom types
            if property.isCustomClass{
                let rProperty = relationProperty(className)
                addFileWithName(&property.type, jsonObject: value as NSDictionary, files:&files, toOneRelationWithProperty: rProperty)
            }else if property.isArray{
                let array = value as NSArray
                if array.firstObject is NSDictionary{
                    
                    //complicated enough.....
                    var type = typeNameForPropertyName(property.jsonName)
                    let rProperty = relationProperty(className)
                    let allProperties = unionDictionaryFromArrayElements(array);
                    addFileWithName(&type, jsonObject: allProperties, files:&files, toOneRelationWithProperty: rProperty)
                }
            }
            
            properties.append(property)
            
        }
        
        //create the file
       
        let file = FileRepresenter(className: className, properties: properties, lang:lang)
        
        file.includeUtilities = includeUtilities
        file.includeConstructors = includeConstructors
        file.firstLine = firstLine
        file.parentClassName = parentClassName
        //TODO: - Check if this file already has similar file, if so merge.
        var exactMatchFound = false
        if let similarFile = findSimilarFile(file, inFiles: &files, exactMatchFound: &exactMatchFound){
            //there is a similar file
            if !exactMatchFound{
                //If the found file is no exact, then any additional properties to the alread exist file instead of creating new one
                mergeProperties(fromFile: file, toFile: similarFile)
                
            }
            className = similarFile.className
            
        }else{
            files.append(file)
            
            if lang.headerFileData != nil{
                //add header file first
                let headerFile = HeaderFileRepresenter(className: className, properties: properties, lang:lang)
                headerFile.includeUtilities = includeUtilities
                headerFile.includeConstructors = includeConstructors
                headerFile.parentClassName = parentClassName
                headerFile.firstLine = firstLine
                files.append(headerFile)
            }
        }
    }
    
    /**
    Merges the properties from the passed fromFile to the pass toFile
    :param: fromFile in which to find any new properties
    :param: toFile to which to add any found new properties
    */
    func mergeProperties(#fromFile: FileRepresenter, toFile: FileRepresenter)
    {
        for property in fromFile.properties{
            if find(toFile.properties, property) == nil{
                toFile.properties.append(property)
            }
        }
    }
    
    /**
    Finds the first file in the passed files which has the same class name as the passed file
    
    :param: file the file to compare against
    :param: inFiles the files array to search in
    :param: exactMathFound inout param, will have the value of 'true' if any file is found that has exactly the same properties as the passed file
    :returns: similar file if any
    */
    func findSimilarFile(file: FileRepresenter, inout inFiles files: [FileRepresenter], inout exactMatchFound: Bool) -> FileRepresenter?{
        var similarFile : FileRepresenter?
        for targetFile in files{
            
            exactMatchFound = bothFilesHasSamePropreties(file1: targetFile, file2: file)
            
            if exactMatchFound || targetFile.className == file.className{
                similarFile = targetFile
                
                break
            }
        }
        
        return similarFile
    }
    
    /**
    Compares the properties of both files to determine if they exactly similar or no.
    
    :param: file1 first file to compare against the second file
    :param: file2 the second file to compare against the first file
    :returns: whether both files has exactly the same properties
    */
    func bothFilesHasSamePropreties(#file1: FileRepresenter, file2: FileRepresenter) -> Bool
    {
        var bothHasSameProperties = true
        if file1.properties.count == file2.properties.count{
            //there is a propability they both has the same properties
            for property in file1.properties{
                if find(file2.properties, property) == nil{
                    //property not found, no need to keep looking
                    bothHasSameProperties = false
                    break
                }
            }
        }else{
            bothHasSameProperties = false
        }
        
        return bothHasSameProperties
    }
    
    /**
    Creates and returns a dictionary who is built up by combining all the dictionary elements in the passed array.
    
    :param: array array of dictionaries.
    :returns: dictionary that combines all the dictionary elements in the array.
    */
    func unionDictionaryFromArrayElements(array: NSArray) -> NSDictionary
    {
        var dictionary = NSMutableDictionary()
        for item in array{
            if let dic = item as? NSDictionary{
                //loop all over its keys
                for key in dic.allKeys as [String]{
                    dictionary[key] = dic[key]
                }
            }
        }
        
        
        return dictionary
    }
    
    /**
    Creates and returns a Property object whiche represents a to-one relation property
    
    :param: relationClassName to which the relation relates
    :param: headerProperty optional whether this property is for header file
    
    :returns: the relation property
    */
    func relationProperty(relationClassName : String) -> Property
    {
        
        let nativeName = relationClassName.lowercaseFirstChar()
        let property = Property(jsonName: nativeName, nativeName: nativeName, type: relationClassName, lang: lang)
        property.isCustomClass = true
        
        return property
    }
    
    /**
    Creates and returns a Property object passed on the passed value and json key name
    
    :param: value example value for the property
    :param: jsonKeyName for the property
    :returns: a Property instance
    */
    func propertyForValue(value: AnyObject, jsonKeyName: String) -> Property
    {
        let nativePropertyName = propertyNativeName(jsonKeyName)
        var type = propertyTypeName(value, lang:lang)
        var isDictionary = false
        var isArray = false
        
        var property: Property!
        if value is NSDictionary {
            type = typeNameForPropertyName(jsonKeyName)
            property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, isArray:false, isCustomClass: true, lang: lang)
            
        }else if value is NSArray{
            //we need to check its elements...
            let array = value as NSArray
            if let dic = array.firstObject? as? NSDictionary{
                //wow complicated
                let leafClassName = typeNameForPropertyName(jsonKeyName)

                type = lang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: leafClassName)
                
                property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, isArray: true, isCustomClass: false, lang:lang)
                property.elementsType = leafClassName
                property.elementsAreOfCustomType = true
            }else{
                property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, isArray: true, isCustomClass: false, lang:lang)
                property.elementsType = typeNameForArrayElements(value as NSArray, lang:lang)
            }
        }else{
            property = Property(jsonName: jsonKeyName, nativeName: nativePropertyName, type: type, lang:lang)
        }
        property.sampleValue = value
        return property
    }
    

    
    
    /**
    Returns a camel case presentation from the passed json key
    
    :param: jsonKeyName the name of the json key to convert to suitable native property name
    
    :returns: property name
    */
    func propertyNativeName(jsonKeyName : String) -> String
    {
        return underscoresToCamelCaseForString(jsonKeyName, startFromFirstChar: false).lowercaseFirstChar()
    }
    
    /**
    Returns the input string with white spaces removed, and underscors converted to camel case
    
    :param: inputString to convert
    :param: startFromFirstChar whether to start with upper case letter
    :returns: the camel case version of the input
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
    
    :param: propertyName to be converted to a type name
    :returns: the type name
    */
    func typeNameForPropertyName(propertyName : String) -> String{
        var swiftClassName = underscoresToCamelCaseForString(propertyName, startFromFirstChar: true).toSingular()
        
        if !swiftClassName.hasPrefix(classPrefix){
            swiftClassName = "\(classPrefix)\(swiftClassName)"
        }
        
        return swiftClassName
    }
    
}