//
//	DataType.swift
//
//	Create by Ahmed Ali on 14/11/2014
//	Copyright (c) 2014 Mobile Developer. All rights reserved.
//

import Foundation

class DataType{

	var boolType : String!
	var characterType : String!
	var doubleType : String!
	var floatType : String!
	var intType : String!
	var longType : String!
	var stringType : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		boolType = dictionary["boolType"] as? String
		characterType = dictionary["characterType"] as? String
		doubleType = dictionary["doubleType"] as? String
		floatType = dictionary["floatType"] as? String
		intType = dictionary["intType"] as? String
		longType = dictionary["longType"] as? String
		stringType = dictionary["stringType"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if boolType != nil{
			dictionary["boolType"] = boolType
		}
		if characterType != nil{
			dictionary["characterType"] = characterType
		}
		if doubleType != nil{
			dictionary["doubleType"] = doubleType
		}
		if floatType != nil{
			dictionary["floatType"] = floatType
		}
		if intType != nil{
			dictionary["intType"] = intType
		}
		if longType != nil{
			dictionary["longType"] = longType
		}
		if stringType != nil{
			dictionary["stringType"] = stringType
		}
		return dictionary
	}

}