//
//	UtilityMethod.swift
//
//	Create by Ahmed Ali on 14/11/2014
//	Copyright (c) 2014 Mobile Developer. All rights reserved.
//

import Foundation

class UtilityMethod{

	
	var body : String!
	var bodyEnd : String!
	var bodyStart : String!
	var comment : String!
	var forEachArrayOfCustomTypeProperty : String!
	var forEachProperty : String!
    var forEachCustomTypeProperty : String!
	var returnStatement : String!
	var signature : String!
    var forEachPropertyWithSpecialStoringNeeds : String!

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		forEachCustomTypeProperty = dictionary["forEachCustomTypeProperty"] as? String
		body = dictionary["body"] as? String
		bodyEnd = dictionary["bodyEnd"] as? String
		bodyStart = dictionary["bodyStart"] as? String
		comment = dictionary["comment"] as? String
		forEachArrayOfCustomTypeProperty = dictionary["forEachArrayOfCustomTypeProperty"] as? String
		forEachProperty = dictionary["forEachProperty"] as? String
		returnStatement = dictionary["returnStatement"] as? String
		signature = dictionary["signature"] as? String
        forEachPropertyWithSpecialStoringNeeds = dictionary["forEachPropertyWithSpecialStoringNeeds"] as? String
	}

	

}