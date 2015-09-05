JSONExport
==========
JSONExport is a desktop application for Mac OS X written in Swift. 
Using JSONExport you will be able to:
* Convert any valid JSON object to a class of one of the currently supported languages.
* Preview the generated content before saving it.
* Include constructors only, utility methods only, both or none.
* Change the root class name.
* Set a class name prefix for the generated classes.
* Set package name for Java files.

Generated Files
========================
Each generated file, besid the getters and setters (for Java) can include:
* A constructor wich accepts an instance of NSDictionary, JSON, JSONObject instance depending on the file language, and the class will use this object to fill its properties data.
* A utility method which converts the class data into a dictionary again.

Currently supported languages
========================
Currently you can convert your JSON object to one of the following lanaguages:

1. Java for Android.
2. Java for Android - to use with [Realm](http://realm.io).
3. Swift Classes.
4. Swift Classes - To use with [SwiftyJSON](https://github.com/lingoer/SwiftyJSON) library.
5. Swift Classes - To use with [Realm](http://realm.io).
6. Swift - CoreData.
7. Swift Sturcutres.
8. Objective-C - iOS.
9. Objective-C - MAC.
10. Objective-C - CoreData.
11. Objective-C - To use with [Realm](http://realm.io).

Screenshot shows JSONExport used for a snippet from Twitter timeline JSON and converting it to Swift-CoreData.
![alt tag](https://cloud.githubusercontent.com/assets/5157350/5228493/72693010-7713-11e4-9e42-625a8590424a.png)

Installation
========================
Kindly clone the project, and build it using xCode 6.1+ on any Mac OS X 10.10 or above.

To Do
========================
* ~~Support Objective-C~~ Done
* ~~Sync multible classes with the same name or have the same exact properties~~ Done
* ~~Support to parse JSON arrays of objects~~ Done
* Load JSON data from web
* Open .json files with JSONExport
* Supported languages management editor.
* Beside raw JSON, load the model raw data from plist files as well.


Known Limitions:
========================
* When exporting to subclasses of NSManagedObject, some data types can not be exported. For example core data does not have data type for "array of strings"; in turn, if your JSON contains an array of strings, the exported file will not compile without you fixing the type mismatch.
* When exporting subclasses of RLMObject, you will have to enter the default values of premitive types manually. This is because of dynamic properties limition that prevents you from having an optional premitive type.
* When exporting to CoreData or Realm and you want to use the utility methods, you will need to manually watch for deep relation cycle calls; that is, when you convert an object to dictionary, this object try to convert one of its relation to a dictionary and the relation tries to convert the original object to a dictionary, that will cause a kind of cycle where each object involved calls the other object's toDictionary method infenitly...
* Avoid attempt to model a JSON object with empty values, because JSONExport does not understand empty values and can not guess their types.

History log:
========================
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

Final Note
========================
The application still in its early stage. Please report any issue so I can improve it.

License
========================
JSONExport is available under custom version of **MIT** license.
