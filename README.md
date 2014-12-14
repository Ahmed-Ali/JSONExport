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
* Sync multible classes with the same name (if a conflict happen)
* Accept JSON arrays
* Load JSON data from web
* Open .json files with JSONExport
* Supported languages management editor.


Known Issues:
========================
* When exporting to subclasses of NSManagedObject some data types can not be exported. For example core data does not have data type for "array of strings"; in turn, if your JSON contains an array of strings, the exported file will not compile without you fixing the type mismatch.

History log:
========================
* Version 0.0.3:
  - Added support for Realm with Android.
  - Added support to specify parent class for all generated classes.

Final Note
========================
The application still in its early stages. Please report any issue so I can improve it.

License
========================
JSONExport is available under _MIT_ license.
