//
//	LangModel.swift
//
//	Create by Ahmed Ali on 10/11/2014
//	Copyright (c) 2014 Mobile Developer. All rights reserved.
//

import Foundation

class LangModel{

	var arrayType : String!
	var booleanGetter : String!
	var constructors : [Constructor]!
	var dataTypes : DataType!
	var displayLangName : String!
	var fileExtension : String!
	var genericType : String!
	var getter : String!
	var importForEachCustomType : String!
	var instanceVarDefinition : String!
	var langName : String!
	var modelDefinition : String!
	var modelEnd : String!
	var modelStart : String!
	var setter : String!
	var staticImports : String!
	var utilityMethods : [UtilityMethod]!
	var wordsToRemoveToGetArrayElementsType : [String]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		arrayType = dictionary["arrayType"] as? String
		booleanGetter = dictionary["booleanGetter"] as? String
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
		displayLangName = dictionary["displayLangName"] as? String
		fileExtension = dictionary["fileExtension"] as? String
		genericType = dictionary["genericType"] as? String
		getter = dictionary["getter"] as? String
		importForEachCustomType = dictionary["importForEachCustomType"] as? String
		instanceVarDefinition = dictionary["instanceVarDefinition"] as? String
		langName = dictionary["langName"] as? String
		modelDefinition = dictionary["modelDefinition"] as? String
		modelEnd = dictionary["modelEnd"] as? String
		modelStart = dictionary["modelStart"] as? String
		setter = dictionary["setter"] as? String
		staticImports = dictionary["staticImports"] as? String
		utilityMethods = [UtilityMethod]()
		if let utilityMethodsArray = dictionary["utilityMethods"] as? [NSDictionary]{
			 for dic in utilityMethodsArray{
				let value = UtilityMethod(fromDictionary: dic)
				utilityMethods.append(value)
			}
		}
		wordsToRemoveToGetArrayElementsType = dictionary["wordsToRemoveToGetArrayElementsType"] as? [String]
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		var dictionary = NSMutableDictionary()
		if arrayType != nil{
			dictionary["arrayType"] = arrayType
		}
		if booleanGetter != nil{
			dictionary["booleanGetter"] = booleanGetter
		}
		if constructors != nil{
			var dictionaryElements = [NSDictionary]()
			for constructorsElement in constructors {
				dictionaryElements.append(constructorsElement.toDictionary())
			}
			dictionary["constructors"] = dictionaryElements
		}
		if dataTypes != nil{
			dictionary["dataTypes"] = dataTypes.toDictionary()
		}
		if displayLangName != nil{
			dictionary["displayLangName"] = displayLangName
		}
		if fileExtension != nil{
			dictionary["fileExtension"] = fileExtension
		}
		if genericType != nil{
			dictionary["genericType"] = genericType
		}
		if getter != nil{
			dictionary["getter"] = getter
		}
		if importForEachCustomType != nil{
			dictionary["importForEachCustomType"] = importForEachCustomType
		}
		if instanceVarDefinition != nil{
			dictionary["instanceVarDefinition"] = instanceVarDefinition
		}
		if langName != nil{
			dictionary["langName"] = langName
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
		if setter != nil{
			dictionary["setter"] = setter
		}
		if staticImports != nil{
			dictionary["staticImports"] = staticImports
		}
		if utilityMethods != nil{
			var dictionaryElements = [NSDictionary]()
			for utilityMethodsElement in utilityMethods {
				dictionaryElements.append(utilityMethodsElement.toDictionary())
			}
			dictionary["utilityMethods"] = dictionaryElements
		}
		if wordsToRemoveToGetArrayElementsType != nil{
			dictionary["wordsToRemoveToGetArrayElementsType"] = wordsToRemoveToGetArrayElementsType
		}
		return dictionary
	}

}