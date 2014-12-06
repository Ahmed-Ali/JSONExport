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

1. Java for Android - using org.json.* classes.
2. Swift Classes.
3. Swift Sturcutres.
4. Swift Classes - Uses [SwiftyJSON](https://github.com/lingoer/SwiftyJSON) library.
5. Swift - CoreData.
6. Objective-C - iOS.
7. Objective-C - MAC.
8. Objective-C - CoreData.
9. Objective-C - [Realm](http://realm.io).
10. Swift Classes - [Realm](http://realm.io).

Screenshot shows JSONExport used for a snippet from Twitter timeline JSON and converting it to Swift-CoreData.
![alt tag](https://cloud.githubusercontent.com/assets/5157350/5228493/72693010-7713-11e4-9e42-625a8590424a.png)

Installation
========================
Kindly clone the project, build it using xCode 6.1+ on any Mac OS X 10.10 or above.

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


Final Note
========================
The application still in it early stages. Please report any issue so I can improve it.
