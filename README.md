iOS Binary Analyzer
===================

Script to analyze an iOS binary and check which security features/measures are enabled.

Checks
------

* Encryption;
* PIE (Position-Independent Executable);
* Stack Smashing Protection;
* Automatic Reference Counting (ARC).

Dependencies
------------

iOS Binary Analyzer depends on the _otool_ command, thus make sure that it is installed.

Using Cydia, _otool_ can be found in the following package:

* [Darwin CC Tools](http://apt.thebigboss.org/onepackage.php?bundleid=org.coolstar.cctools)

