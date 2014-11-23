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

:param: value example value to figure out its type
:returns: the type name
*/
func propertyTypeName(value : AnyObject, #lang: LangModel) -> String
{
    var name = ""
    if value is NSArray{
        name = typeNameForArrayOfElements(value as NSArray, lang:lang)
    }else if value is NSNumber{
        name = typeForNumber(value as NSNumber, lang: lang)
    }else if value is NSString{
        let booleans : [String] = ["True", "true", "TRUE", "False", "false", "FALSE"]
        if find(booleans, value as String) != nil{
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

:param: elements array to try to find out which type is suitable for its elements

:returns: typeName the type name as String
*/

func typeNameForArrayElements(elements: NSArray, #lang: LangModel) -> String{
    var typeName : String!
    let genericType = lang.genericType
    if elements.count == 0{
        typeName = genericType
    }
    for element in elements{
        let currElementTypeName = propertyTypeName(element, lang: lang)
        
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

:param: elements array to try to find out which type is suitable for its elements

:returns: the type name
*/
func typeNameForArrayOfElements(elements: NSArray, #lang: LangModel) -> String{
    var typeName : String!
    let genericType = lang.arrayType.stringByReplacingOccurrencesOfString(elementType, withString: lang.genericType)
    if elements.count == 0{
        typeName = genericType
    }
    for element in elements{
        let currElementTypeName = propertyTypeName(element, lang: lang)
        
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

:param: number the numeric value
:returns: the type name
*/
func typeForNumber(number : NSNumber, #lang: LangModel) -> String
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