* Version 1.0.3
	- Merged pull request #45 to add support Android GSON (Thanks to forestsoftjpdev)

* Version 1.0.2
	- Merged pull request #43 to add support for Swift 3 for Mappable classes (Thanks to amolgupta)
	- Merged pull request #44 to add support for Unbox structures (Thanks to baroqueworksdev)
	
* Version 1.0.1
	- Merged pull request #38 to add support to Gloss (Thanks to CodeEagle help)
	- Add "author" section in the lang files, so when you contribute by adding a definition of a language, you can add your "name", "email", "website" on top of every generated file of the language you added. See the Swift-Struct-Gloss.json" author key for an example.

* Version 1.0.0
	- Merged pull requests #28 and #31
	- The app seems to be stable enough at this point

* Version 0.0.9
  - Merged pull request #25 for support to Xcode 7 and Swift 2.0
* Version 0.0.8
  - Added reserved keywords for each language; json keys that has one of these keywords (eg: {"false": "This is false value"}), will be handled approperiately.
  - Fix for issue #10, whcih prevented the creation of some classes/structs in some cases.
  - Added NSCoding support for the following language definitions: Swift-Classes, Swift-Mappable, SwiftyJSON, Swift-Realm, Objective-C iOS, Mac and Realm.

* Version 0.0.7
  - Few changes by tomkidd for xCode 6.3 and Swift 1.2

* Version 0.0.6
  - JSONExport will first remove any control characters before parsing the JSON object. So it will able to parse your JSON even if it has control characters.
  - Double check property names to avoid unwanted spaces (issue #5 thanks to falcon2010).
  - Processing JSON now happens in background queue for better responsiveness.
  - For Java (with and without Realm) parsing of array of strings (issue #6 thanks to falcon2010)

* Version 0.0.5:
  - Fixed an issue where float values would be generated into Int property (Thanks to jmonroe).
  - Updated SiwftyJSON language definition to match the current version (Thanks to  jmonroe).
  - Fixed typo in CGGFloat instead of CGFloat.
  - In Objective-C check against NSNull values.
  - Swift realm, initialize using class methods instead of initializers.
  - Swift perimitive types now casted directly instead of cating to NSString first.

* Version 0.0.4:
  - Sync multible classes with the same name or have the same exact properties.
  - Support to parse JSON arrays of objects.

* Version 0.0.3:
  - Added support for Realm with Android.
  - Added support to specify parent class for all generated classes.
