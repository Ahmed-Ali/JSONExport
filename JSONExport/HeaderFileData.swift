//
//	HeaderFileData.swift
//
//	Create by Ahmed Ali on 23/11/2014
//	Copyright © 2014 Mobile Developer. All rights reserved.
//

import Foundation

class HeaderFileData{
    
    var constructorSignatures : [String]!
    var headerFileExtension : String!
    var importForEachCustomType : String!
    var instanceVarDefinition : String!
    var instanceVarWithSpeicalDefinition : String!
    var modelDefinition : String!
    var modelEnd : String!
    var modelStart : String!
    var staticImports : String!
    var typesNeedSpecialDefinition : [String]!
    var utilityMethodSignatures : [String]!
    
    
    /**
    * Instantiate the instance using the passed dictionary values to set the properties values
    */
    init(fromDictionary dictionary: NSDictionary){
        constructorSignatures = dictionary["constructorSignatures"] as? [String]
        headerFileExtension = dictionary["headerFileExtension"] as? String
        importForEachCustomType = dictionary["importForEachCustomType"] as? String
        instanceVarDefinition = dictionary["instanceVarDefinition"] as? String
        instanceVarWithSpeicalDefinition = dictionary["instanceVarWithSpeicalDefinition"] as? String
        modelDefinition = dictionary["modelDefinition"] as? String
        modelEnd = dictionary["modelEnd"] as? String
        modelStart = dictionary["modelStart"] as? String
        staticImports = dictionary["staticImports"] as? String
        typesNeedSpecialDefinition = dictionary["typesNeedSpecialDefinition"] as? [String]
        utilityMethodSignatures = dictionary["utilityMethodSignatures"] as? [String]
        
    }
    
    /**
    * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
    */
    func toDictionary() -> NSDictionary
    {
        var dictionary = NSMutableDictionary()
        if constructorSignatures != nil{
            dictionary["constructorSignatures"] = constructorSignatures
        }
        if headerFileExtension != nil{
            dictionary["headerFileExtension"] = headerFileExtension
        }
        if importForEachCustomType != nil{
            dictionary["importForEachCustomType"] = importForEachCustomType
        }
        if instanceVarDefinition != nil{
            dictionary["instanceVarDefinition"] = instanceVarDefinition
        }
        if instanceVarWithSpeicalDefinition != nil{
            dictionary["instanceVarWithSpeicalDefinition"] = instanceVarWithSpeicalDefinition
        }
        if modelDefinition != nil{
            dictionary["modelDefinition"] = modelDefinition
        }
        if modelEnd != nil{
            dictionary["modelEnd"] = modelEnd
        }
        if modelStart != nil{
            dictionary["modelStart"] = modelStart
        }
        if staticImports != nil{
            dictionary["staticImports"] = staticImports
        }
        if typesNeedSpecialDefinition != nil{
            dictionary["typesNeedSpecialDefinition"] = typesNeedSpecialDefinition
        }
        if utilityMethodSignatures != nil{
            dictionary["utilityMethodSignatures"] = utilityMethodSignatures
        }
        return dictionary
    }
}