//
//	LangModel.swift
//
//	Create by Ahmed Ali on 14/11/2014
//	Copyright (c) 2014 Mobile Developer. All rights reserved.
//

import Foundation

class LangModel{

	var arrayType : String!
	var basicTypesWithSpecialFetchingNeeds : [String]!
    var basicTypesWithSpecialFetchingNeedsReplacements : [String]!
    var basicTypesWithSpecialStoringNeeds : [String]!
	var booleanGetter : String!
    var briefDescription : String!
    var constructors : [Constructor]!
	var dataTypes : DataType!
	var displayLangName : String!
	var fileExtension : String!
	var genericType : String!
	var getter : String!
	var importForEachCustomType : String!
    var importHeaderFile : String!
	var instanceVarDefinition : String!
    var instanceVarWithSpeicalDefinition : String!
    var typesNeedSpecialDefinition : [String]!
	var langName : String!
    var constVarDefinition : String!
	var modelDefinition : String!
    var modelDefinitionWithParent : String!
    var defaultParentWithUtilityMethods : String!
	var modelEnd : String!
	var modelStart : String!
	var setter : String!
	var staticImports : String!
	var supportsFirstLineStatement : Bool!
    var firstLineHint : String!
	var utilityMethods : [UtilityMethod]!
    var reservedKeywords : [String]!
	var wordsToRemoveToGetArrayElementsType : [String]!
    var headerFileData : HeaderFileData!
    var supportMutualRelationships : Bool!

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		arrayType = dictionary["arrayType"] as? String
		basicTypesWithSpecialFetchingNeeds = dictionary["basicTypesWithSpecialFetchingNeeds"] as? [String]
        basicTypesWithSpecialFetchingNeedsReplacements = dictionary["basicTypesWithSpecialFetchingNeedsReplacements"] as? [String]
        basicTypesWithSpecialStoringNeeds = dictionary["basicTypesWithSpecialStoringNeeds"] as? [String]
		booleanGetter = dictionary["booleanGetter"] as? String
        briefDescription = dictionary["briefDescription"] as? String
        
		constructors = [Constructor]()
		if let constructorsArray = dictionary["constructors"] as? [NSDictionary]{
			 for dic in constructorsArray{
				let value = Constructor(fromDictionary: dic)
				constructors.append(value)
			}
		}
		if let dataTypesData = dictionary["dataTypes"] as? NSDictionary{
				dataTypes = DataType(fromDictionary: dataTypesData)
			}
        importHeaderFile = dictionary["importHeaderFile"] as? String
		displayLangName = dictionary["displayLangName"] as? String
		fileExtension = dictionary["fileExtension"] as? String
		genericType = dictionary["genericType"] as? String
		getter = dictionary["getter"] as? String
		importForEachCustomType = dictionary["importForEachCustomType"] as? String
		instanceVarDefinition = dictionary["instanceVarDefinition"] as? String
        instanceVarWithSpeicalDefinition = dictionary["instanceVarWithSpeicalDefinition"] as? String
        typesNeedSpecialDefinition = dictionary["typesNeedSpecialDefinition"] as? [String]
        
		langName = dictionary["langName"] as? String
        constVarDefinition = dictionary["constVarDefinition"] as? String
		modelDefinition = dictionary["modelDefinition"] as? String
        modelDefinitionWithParent = dictionary["modelDefinitionWithParent"] as? String
        defaultParentWithUtilityMethods = dictionary["defaultParentWithUtilityMethods"] as? String
		modelEnd = dictionary["modelEnd"] as? String
		modelStart = dictionary["modelStart"] as? String
		setter = dictionary["setter"] as? String
		staticImports = dictionary["staticImports"] as? String
		supportsFirstLineStatement = (dictionary["supportsFirstLineStatement"] as? NSString)?.boolValue
        firstLineHint = dictionary["firstLineHint"] as? String
		utilityMethods = [UtilityMethod]()
		if let utilityMethodsArray = dictionary["utilityMethods"] as? [NSDictionary]{
			 for dic in utilityMethodsArray{
				let value = UtilityMethod(fromDictionary: dic)
				utilityMethods.append(value)
			}
		}
        reservedKeywords = dictionary["reservedKeywords"] as? [String]
		wordsToRemoveToGetArrayElementsType = dictionary["wordsToRemoveToGetArrayElementsType"] as? [String]
        
        if let headerFileDataData = dictionary["headerFileData"] as? NSDictionary{
            headerFileData = HeaderFileData(fromDictionary: headerFileDataData)
        }
        
        supportMutualRelationships = (dictionary["supportMutualRelationships"] as? NSString)?.boolValue
	}

	

}