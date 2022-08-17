'''
updates the version numbers in the build files according to our design

simply run the script with the name of the build you wish to increment
and it will increment the version number in the ios/Flutter/Generate.xcconfig
file and the android/local.properties file respective to the specified platform.

once modifications are made to the build files, the script will also save
it locally to the version file.

if you wish to only view the version, simply add no flags
if you wish to increment only the build number, simply add the -b flag
if you wish to increment the patch number and build number, simply add the -p flag
if you wish to increment the minor number and build number, simply add the --minor flag
if you wish to increment the major number and build number, simply add the --major flag
if you wish to specify the entire version, simply add the --set flag


examples: 

> python version.py ios
1.4.1+13

> python version.py android 
1.0.1+2

> python version.py ios -b
1.4.1+13 -> 1.4.1+14
saved!

> python version.py android -p 
1.0.1+2 -> 1.0.2+3
saved!

> python version.py android --minor
1.0.1+3 -> 1.1.0+4
saved!

> python version.py android --set 1.2.3+4
1.1.0+4 -> 1.2.3+4
saved!
'''