//
//	UtilityMethod.swift
//
//	Create by Ahmed Ali on 10/11/2014
//	Copyright (c) 2014 Mobile Developer. All rights reserved.
//

import Foundation

class UtilityMethod{

	var additionalyForEachCustomTypeProperty : String!
	var body : String!
	var bodyEnd : String!
	var bodyStart : String!
	var comment : String!
	var forEachArrayOfCustomTypeProperty : String!
	var forEachProperty : String!
	var returnStatement : String!
	var signature : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		additionalyForEachCustomTypeProperty = dictionary["additionalyForEachCustomTypeProperty"] as? String
		body = dictionary["body"] as? String
		bodyEnd = dictionary["bodyEnd"] as? String
		bodyStart = dictionary["bodyStart"] as? String
		comment = dictionary["comment"] as? String
		forEachArrayOfCustomTypeProperty = dictionary["forEachArrayOfCustomTypeProperty"] as? String
		forEachProperty = dictionary["forEachProperty"] as? String
		returnStatement = dictionary["returnStatement"] as? String
		signature = dictionary["signature"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		var dictionary = NSMutableDictionary()
		if additionalyForEachCustomTypeProperty != nil{
			dictionary["additionalyForEachCustomTypeProperty"] = additionalyForEachCustomTypeProperty
		}
		if body != nil{
			dictionary["body"] = body
		}
		if bodyEnd != nil{
			dictionary["bodyEnd"] = bodyEnd
		}
		if bodyStart != nil{
			dictionary["bodyStart"] = bodyStart
		}
		if comment != nil{
			dictionary["comment"] = comment
		}
		if forEachArrayOfCustomTypeProperty != nil{
			dictionary["forEachArrayOfCustomTypeProperty"] = forEachArrayOfCustomTypeProperty
		}
		if forEachProperty != nil{
			dictionary["forEachProperty"] = forEachProperty
		}
		if returnStatement != nil{
			dictionary["returnStatement"] = returnStatement
		}
		if signature != nil{
			dictionary["signature"] = signature
		}
		return dictionary
	}

}