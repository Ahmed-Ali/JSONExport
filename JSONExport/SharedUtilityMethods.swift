//
//  SharedUtilityMethods.swift
//  JSONExport
//
//  Created by Ahmed Ali on 11/23/14.
//  Copyright (c) 2014 Ahmed Ali. All rights reserved.
//

import Foundation


/**
Creats and returns the type name for the passed value

- parameter value: example value to figure out its type
- returns: the type name
*/
func propertyTypeName(_ value : AnyObject, lang: LangModel) -> String
{
    var name = ""
    if value is NSArray{
        name = typeNameForArrayOfElements(value as! NSArray, lang:lang)
    }else if value is NSNumber{
        name = typeForNumber(value as! NSNumber, lang: lang)
    }else if value is NSString{
        let booleans : [String] = ["True", "true", "TRUE", "False", "false", "FALSE"]
        if booleans.index(of: (value as! String)) != nil{
            name = lang.dataTypes.boolType
        }else{
            name = lang.dataTypes.stringType
        }
    }else if value is NSNull{
        name = lang.genericType
    }
    
    return name
}

/**
Tries to figur out the type of the elements of the passed array and returns the type that can be used as the type of any element in the array

- parameter elements: array to try to find out which type is suitable for its elements

- returns: typeName the type name as String
*/

func typeNameForArrayElements(_ elements: NSArray, lang: LangModel) -> String{
    var typeName : String!
    let genericType = lang.genericType
    if elements.count == 0{
        typeName = genericType
    }
    for element in elements{
        let currElementTypeName = propertyTypeName(element as AnyObject, lang: lang)
        
        if typeName == nil{
            typeName = currElementTypeName
            
        }else{
            if typeName != currElementTypeName{
                typeName = genericType
                break
            }
        }
    }
    
    return typeName
}

/**
Tries to figur out the type of the elements of the passed array and returns the type of the array that can hold these values

- parameter elements: array to try to find out which type is suitable for its elements

- returns: the type name
*/
func typeNameForArrayOfElements(_ elements: NSArray, lang: LangModel) -> String{
    var typeName : String!
    let genericType = lang.arrayType.replacingOccurrences(of: elementType, with: lang.genericType)
    if elements.count == 0{
        typeName = genericType
    }
    for element in elements{
        let currElementTypeName = propertyTypeName(element as AnyObject, lang: lang)
        
        let arrayTypeName = lang.arrayType.replacingOccurrences(of: elementType, with: currElementTypeName)
        
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

- parameter number: the numeric value
- returns: the type name
*/
func typeForNumber(_ number : NSNumber, lang: LangModel) -> String
{
    let numberType = CFNumberGetType(number as CFNumber)
    
    var typeName : String!
    switch numberType{
    case .charType:
        if (number.int32Value == 0 || number.int32Value == 1){
            //it seems to be boolean
            typeName = lang.dataTypes.boolType
        }else{
            typeName = lang.dataTypes.characterType
        }
    case .shortType, .intType:
        typeName = lang.dataTypes.intType
    case .floatType, .float32Type, .float64Type:
        typeName = lang.dataTypes.floatType
    case .doubleType:
        typeName = lang.dataTypes.doubleType
    case .longType, .longLongType:
        typeName = lang.dataTypes.longType
    default:
        typeName = lang.dataTypes.intType
    }
    
    return typeName
}


/**
Creates and returns a dictionary who is built up by combining all the dictionary elements in the passed array.

- parameter array: array of dictionaries.
- returns: dictionary that combines all the dictionary elements in the array.
*/
func unionDictionaryFromArrayElements(_ array: NSArray) -> NSDictionary
{
    let dictionary = NSMutableDictionary()
    for item in array{
        if let dic = item as? NSDictionary{
            //loop all over its keys
            for key in dic.allKeys as! [String]{
                dictionary[key] = dic[key]
            }
        }
    }
    return dictionary
}


/**
Cleans up the passed string from any characters that can make it invalid JSON string.

- parameter jsonStr: the JSON string to be cleaned up
- returns: a clean version of the passed string
*/

func jsonStringByRemovingUnwantedCharacters(_ jsonString: String) -> String
{
    var str = jsonString;
    str = str.replacingOccurrences(of: "“", with: "\"")
    str = str.replacingOccurrences(of: "”", with: "\"")
    return stringByRemovingControlCharacters(str)
}

/**
Cleans up the passed string from any control characters.

- parameter string: the string to be cleaned up
- returns: a clean version of the passed string
*/

func stringByRemovingControlCharacters(_ string: String) -> String
{
    let controlChars = CharacterSet.controlCharacters
    var range = string.rangeOfCharacter(from: controlChars)
    var cleanString = string;
    while range != nil && !range!.isEmpty{
        cleanString = cleanString.replacingCharacters(in: range!, with: "")
        range = cleanString.rangeOfCharacter(from: controlChars)
    }
    
    return cleanString
    
}



func runOnBackground(_ task: @escaping () -> Void)
{
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: { () -> Void in
        task();
    })
}

func runOnUiThread(_ task: @escaping () -> Void)
{
    DispatchQueue.main.async(execute: { () -> Void in
        task();
    })
}

