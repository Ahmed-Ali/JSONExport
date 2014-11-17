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
2. Swift Classes - parses the JSON using built-in NSJSONSerialization.
3. Swift Sturcutres - parses the JSON using built-in NSJSONSerialization.
4. Swift Classes - parses the JSON using [SwiftyJSON](https://github.com/lingoer/SwiftyJSON)

Installation
========================
Kindly clone the project, build it using xCode 6.1+ on any Mac OS X 10.10 or above.

To Do
========================
* Support Objective-C
* Sync multible classes with the same name (if a conflict happen)
* Accept JSON arrays
* Load JSON data from web
* Open .json files with JSONExport
* Supported languages management editor.
* Try to use [HanSON](https://github.com/timjansen/hanson/) while working on the supported language JSON files, so the formatting of the file can be more readable.

Final Note
========================
The application still in it early stages. Please report any issue so I can improve it.
